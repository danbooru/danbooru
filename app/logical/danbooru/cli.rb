# frozen_string_literal: true

module Danbooru
  # A command-line tool for managing a Danbooru instance. See bin/booructl for the script that runs it, and
  # app/logical/danbooru/cli/ for the subcommands.
  #
  # Usage: `bin/booructl help [COMMAND]`
  #
  # @see https://github.com/rails/thor/wiki
  class CLI < Thor
    namespace "booructl"

    def self.exit_on_failure?
      true
    end

    desc "status", "Show the status of the database, Redis, IQDB, storage, and background jobs"
    def status
      server = ServerStatus.new
      storage = Danbooru.config.storage_manager
      iqdb = IqdbClient.new
      pending_migrations = ActiveRecord::Base.connection_pool.migration_context.open.pending_migrations

      print_table([
        ["Version:", server.danbooru_version.presence || "unknown"],
        ["Environment:", Rails.env],
        ["Postgres:", server.postgres_up? ? "up (#{server.postgres_version})" : "down (#{server.postgres_error})"],
        ["Migrations:", pending_migrations.empty? ? "up to date" : "#{pending_migrations.size} pending (run `bin/rails db:migrate`)"],
        ["Redis:", server.redis_up? ? "up (#{server.redis_version})" : "down"],
        ["IQDB:", iqdb.enabled? ? "enabled (#{iqdb.iqdb_url})" : "disabled"],
        ["Storage:", storage.is_a?(StorageManager::Local) ? "#{storage.class.name} (#{storage.base_dir})" : storage.class.name],
        ["Jobs:", "#{GoodJob::Job.queued.count} queued, #{GoodJob::Job.running.count} running, #{GoodJob::Job.discarded.count} failed"],
      ])
    end

    desc "user SUBCOMMAND", "Create and manage users"
    subcommand "user", CLI::UserCommand

    desc "instance SUBCOMMAND", "Back up, restore, or reset the database and images together"
    subcommand "instance", CLI::InstanceCommand

    desc "db SUBCOMMAND", "Back up, restore, or reset the database"
    subcommand "db", CLI::DbCommand

    desc "images SUBCOMMAND", "Back up, restore, or reset images"
    subcommand "images", CLI::ImagesCommand

    desc "media SUBCOMMAND", "Regenerate thumbnails and metadata for media assets"
    subcommand "media", CLI::MediaCommand

    desc "iqdb SUBCOMMAND", "Manage the IQDB reverse image search index"
    subcommand "iqdb", CLI::IqdbCommand
  end
end
