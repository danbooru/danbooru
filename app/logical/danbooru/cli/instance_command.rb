# frozen_string_literal: true

# `bin/booructl instance` commands for backing up, restoring, and resetting both the database and images at once.
class Danbooru::CLI::InstanceCommand < Danbooru::CLI::Command
  namespace "instance"

  class_option :dry_run, type: :boolean, default: false, desc: "Print the commands that would be run without running them"

  desc "backup DIR", "Back up the database and images to DIR"
  long_desc <<~EOS
    Back up the database to DIR/danbooru-database.pg_dump and the images to DIR/danbooru-images.tar.

    The IQDB index isn't backed up. Rebuild it with `bin/booructl iqdb reindex` after restoring.

    Example: bin/booructl instance backup /backups/2024-01-01
  EOS
  def backup(dir)
    FileUtils.mkdir_p(dir) unless options[:dry_run]
    invoke Danbooru::CLI::DbCommand, :backup, [], output: database_backup(dir), dry_run: options[:dry_run]
    invoke Danbooru::CLI::ImagesCommand, :backup, [], output: images_backup(dir), dry_run: options[:dry_run]
  end

  desc "check DIR", "Check a backup made by `bin/booructl instance backup DIR`"
  def check(dir)
    invoke Danbooru::CLI::DbCommand, :check, [database_backup(dir)], dry_run: options[:dry_run]
    invoke Danbooru::CLI::ImagesCommand, :check, [images_backup(dir)], dry_run: options[:dry_run]
  end

  desc "restore DIR", "Restore the database and images from a backup made by `bin/booructl instance backup DIR`"
  long_desc <<~EOS
    Restore the database and images from a backup made by `bin/booructl instance backup DIR`. The database must be
    empty, unless --force is given.

    Example: bin/booructl instance restore /backups/2024-01-01
  EOS
  option :force, type: :boolean, default: false, desc: "Delete the database before restoring it, if it isn't empty"
  def restore(dir)
    invoke Danbooru::CLI::DbCommand, :restore, [database_backup(dir)], force: options[:force], dry_run: options[:dry_run]
    invoke Danbooru::CLI::ImagesCommand, :restore, [images_backup(dir)], dry_run: options[:dry_run]
    say_error "Done. Run `bin/booructl iqdb reindex` to rebuild the IQDB index." unless options[:dry_run]
  end

  desc "reset", "Delete the database and all images"
  long_desc <<~EOS
    Delete the database and all images. The database is recreated with a fresh schema and seed data. With --empty, the
    database is left with no tables, ready for `bin/booructl instance restore`.

    Example: bin/booructl instance reset --yes
  EOS
  option :yes, type: :boolean, default: false, desc: "Don't ask for confirmation"
  option :empty, type: :boolean, default: false, desc: "Don't load the schema or seed data"
  def reset
    confirm!("This will permanently delete the database and all images.")
    invoke Danbooru::CLI::DbCommand, :reset, [], yes: true, empty: options[:empty], dry_run: options[:dry_run]
    invoke Danbooru::CLI::ImagesCommand, :reset, [], yes: true, dry_run: options[:dry_run]
  end

  private

  def database_backup(dir)
    File.join(dir, "danbooru-database.pg_dump")
  end

  def images_backup(dir)
    File.join(dir, "danbooru-images.tar")
  end
end
