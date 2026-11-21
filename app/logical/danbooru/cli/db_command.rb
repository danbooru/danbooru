# frozen_string_literal: true

# `bin/booructl db` commands for backing up, restoring, and resetting the database.
class Danbooru::CLI::DbCommand < Danbooru::CLI::Command
  namespace "db"

  class_option :dry_run, type: :boolean, default: false, desc: "Print the commands that would be run without running them"

  desc "backup", "Back up the database"
  long_desc <<~EOS
    Back up the database in pg_dump's custom format. Writes to stdout unless --output is given.

    Example: bin/booructl db backup > danbooru-database.pg_dump
  EOS
  option :output, aliases: "-o", type: :string, default: "-", desc: "The file to write the backup to"
  def backup
    run_command(["pg_dump", *connection_args, "--dbname=#{database}", "--format=custom", "--compress=zstd", *file_args(options[:output], "--file")], env: pg_env, error: "Backup failed.")
  end

  desc "check [FILE]", "Check a backup and show how many tables, rows, and indexes it has"
  long_desc <<~EOS
    Check a backup made by `bin/booructl db backup`. Reads from stdin if FILE isn't given.

    Example: bin/booructl db check danbooru-database.pg_dump
  EOS
  def check(file = "-")
    summary = run_command(["pg_restore", "--file=-", *file_args(file)], error: "The backup is incomplete or corrupt.") do |sql|
      # pg_restore prints the SQL it would run. Count the tables, rows, and indexes in it. Each table's rows are between
      # a `COPY` line and a `\.` line.
      tables = rows = indexes = 0
      copying = false

      sql.each_line do |line|
        if copying
          (line == "\\.\n") ? copying = false : rows += 1
        elsif line.start_with?("COPY ")
          copying = true
          tables += 1
        elsif line.match?(/\A(CREATE (UNIQUE )?INDEX |    ADD CONSTRAINT .* (PRIMARY KEY|UNIQUE|EXCLUDE) )/)
          indexes += 1
        end
      end

      "The backup has #{tables} tables, #{rows} rows, and #{indexes} indexes."
    end

    say summary if summary
  end

  desc "restore [FILE]", "Restore the database from a backup"
  long_desc <<~EOS
    Restore the database from a backup made by `bin/booructl db backup`. Reads from stdin if FILE isn't given. The
    database must be empty, unless --force is given.

    Old backups made with pg_dumpall are plain SQL files and won't work. Restore them with
    `bin/rails dbconsole -p < danbooru-database.pg_dump` instead.

    Example: bin/booructl db restore danbooru-database.pg_dump
  EOS
  option :force, type: :boolean, default: false, desc: "Delete the database before restoring it, if it isn't empty"
  def restore(file = "-")
    if options[:force]
      invoke self.class, :reset, [], empty: true, yes: true, dry_run: options[:dry_run]
    elsif ActiveRecord::Base.connection.tables.any?
      raise Thor::Error, "Database #{database} isn't empty. Use --force to delete it first."
    end

    run_command(["pg_restore", *connection_args, "--dbname=#{database}", "--no-owner", "--no-acl", "--exit-on-error", *file_args(file)], env: pg_env, error: "Restore failed. Database #{database} is incomplete.")
    return if options[:dry_run]

    tables, rows, indexes, size = ActiveRecord::Base.connection.select_rows(<<~SQL.squish).first
      SELECT
        (SELECT count(*) FROM pg_stat_user_tables),
        (SELECT coalesce(sum(n_tup_ins), 0)::bigint FROM pg_stat_user_tables),
        (SELECT count(*) FROM pg_indexes WHERE schemaname NOT IN ('pg_catalog', 'information_schema')),
        pg_size_pretty(pg_database_size(current_database()))
    SQL

    say_error "Restored #{tables} tables, #{rows} rows, and #{indexes} indexes to database #{database} (#{size})."
  end

  desc "reset", "Delete the database and recreate it"
  long_desc <<~EOS
    Delete the database and recreate it, with a fresh schema and seed data. Anything still connected to the database is
    disconnected. With --empty, the database is left with no tables, ready for `bin/booructl db restore`.

    Example: bin/booructl db reset --yes
  EOS
  option :yes, type: :boolean, default: false, desc: "Don't ask for confirmation"
  option :empty, type: :boolean, default: false, desc: "Don't load the schema or seed data"
  def reset
    confirm!("This will permanently delete the database #{database} on #{pg_env.fetch("PGHOST", "localhost")}.")

    # Disconnect first, otherwise dropdb kills our connection and the next query fails.
    ActiveRecord::Base.connection_pool.disconnect! unless options[:dry_run]
    run_command(["dropdb", *connection_args, "--if-exists", "--force", "--", database], env: pg_env, error: "Couldn't delete database #{database}.")
    run_command(["createdb", *connection_args, "--", database], env: pg_env, error: "Couldn't create database #{database}.")
    run_command([Rails.root.join("bin/rails").to_s, "db:schema:load", "db:seed"], error: "Couldn't load the schema into database #{database}.") unless options[:empty]
  end

  private

  def database
    pg_env.fetch("PGDATABASE")
  end

  # The command-line arguments for reading or writing a file, or none if the file is "-" (stdin or stdout).
  def file_args(file, flag = "--")
    (file == "-") ? [] : [flag, file]
  end

  # The connection settings as command-line arguments, so they're shown when the command is printed. The password is
  # passed in the environment instead, so it isn't printed.
  def connection_args
    { "--host" => pg_env["PGHOST"], "--port" => pg_env["PGPORT"], "--username" => pg_env["PGUSER"] }.compact.map { |flag, value| "#{flag}=#{value}" }
  end

  def pg_env
    config = ActiveRecord::Base.connection_db_config.configuration_hash

    {
      "PGHOST" => config[:host],
      "PGPORT" => config[:port]&.to_s,
      "PGUSER" => config[:username],
      "PGPASSWORD" => config[:password],
      "PGDATABASE" => config[:database],
    }.compact
  end
end
