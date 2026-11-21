# This file contains commands for running various routine maintenance tasks on
# a Danbooru instance. Run `bin/rails -T` to see a list of all available tasks.
#
# @see https://guides.rubyonrails.org/command_line.html#rake
# @see https://guides.rubyonrails.org/command_line.html#custom-rake-tasks
namespace :danbooru do
  # Usage: bin/rails danbooru:cron
  desc "Run the cronjob scheduler"
  task cron: :environment do
    RackMetricsServer.new.start
    Clockwork.run
  end

  # These tasks are kept for backwards compatibility. Use bin/booructl instead.
  namespace :images do
    desc "Reindex posts in IQDB (deprecated, use `bin/booructl iqdb reindex`)"
    task reindex_iqdb: :environment do
      abort "COND is no longer supported (deprecated, use `bin/booructl iqdb reindex SEARCH`)" if ENV["COND"].present?
      Danbooru::CLI.start(["iqdb", "reindex", *("--dry-run" if ENV.fetch("DRY_RUN", "false").truthy?)])
    end

    desc "Regenerate metadata for media assets (deprecated, use `bin/booructl media regenerate --no-files --no-ai-tags`)"
    task regenerate_metadata: :environment do
      abort "COND is no longer supported (deprecated, use `bin/booructl media regenerate SEARCH --no-files --no-ai-tags`)" if ENV["COND"].present?
      Danbooru::CLI.start(["media", "regenerate", "--no-files", "--no-ai-tags", *("--dry-run" if ENV.fetch("DRY_RUN", "true").truthy?)])
    end

    desc "Backup images to an archive file (deprecated, use `bin/booructl images backup`)"
    task backup: :environment do
      Danbooru::CLI.start(%w[images backup])
    end

    desc "Restore images from backup (deprecated, use `bin/booructl images restore`)"
    task restore: :environment do
      Danbooru::CLI.start(%w[images restore])
    end
  end

  namespace :docker do
    # Usage: bin/rails danbooru:docker:build
    #
    # Build a Docker image. Note that uncommited changes won't be included in the image; commit changes to Git first before building the image.
    desc "Build a Docker image"
    task :build do
      system("bin/build-docker-image")
    end

    # Usage: bin/rails danbooru:docker:build-arm
    #
    # Build a Docker image for ARM. You may need to install QEMU first if building on x86.
    #
    # * sudo apt-get install qemu-system-arm binfmt-support qemu-user-static # Install QEMU
    # * docker run --rm -it --platform linux/arm64 ubuntu                    # Test that QEMU works
    # * docker run --rm -it --platform linux/arm64 danbooru:arm64 bash       # Test that the Danbooru image works
    desc "Build a Docker image for ARM"
    task :"build-arm" do
      system("bin/build-docker-image danbooru linux/arm64")
    end
  end

  # @see app/logical/danbooru_maintenance.rb
  namespace :maintenance do
    # Usage: bin/rails danbooru:maintenance:hourly
    desc "Run hourly maintenance jobs"
    task hourly: :environment do
      DanbooruMaintenance.hourly
    end

    # Usage: bin/rails danbooru:maintenance:daily
    desc "Run daily maintenance jobs"
    task daily: :environment do
      DanbooruMaintenance.daily
    end

    # Usage: bin/rails danbooru:maintenance:weekly
    desc "Run weekly maintenance jobs"
    task weekly: :environment do
      DanbooruMaintenance.weekly
    end

    # Usage: bin/rails danbooru:maintenance:monthly
    desc "Run monthly maintenance jobs"
    task monthly: :environment do
      DanbooruMaintenance.monthly
    end
  end

  # These tasks are kept for backwards compatibility. Use bin/booructl instead.
  namespace :database do
    desc "Back up the database (deprecated, use `bin/booructl db backup`)"
    task backup: :environment do
      Danbooru::CLI.start(%w[db backup])
    end

    desc "Check a database backup (deprecated, use `bin/booructl db check`)"
    task check: :environment do
      Danbooru::CLI.start(%w[db check])
    end

    desc "Restore the database from a backup (deprecated, use `bin/booructl db restore`)"
    task restore: :environment do
      Danbooru::CLI.start(%w[db restore])
    end
  end
end
