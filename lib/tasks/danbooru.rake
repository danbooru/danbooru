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
    Clockwork::run
  end

  desc "Run the Discord bot"
  task discord: :environment do
    Bundler.require(:discord)
    Discord::Bot.new.run
  end

  # Usage: bin/rails danbooru:reindex_iqdb
  #
  # Schedules all posts to be reindexed in IQDB. Requires the jobs
  # worker (bin/good_job) to be running.
  desc "Reindex all posts in IQDB"
  task reindex_iqdb: :environment do
    Post.find_each do |post|
      puts "post ##{post.id}"
      post.update_iqdb
    end
  end

  # Usage: bin/rails danbooru:images:validate
  #
  # Check whether any images are missing, corrupt, or don't match the
  # width/height/size/ext metadata in the database.
  namespace :images do
    task validate: :environment do
      processes = ENV.fetch("PROCESSES", Etc.nprocessors).to_i

      MediaAsset.active.parallel_find_each(in_processes: processes) do |asset|
        media_file = asset.variant(:original).open_file

        raise if asset.md5 != media_file.md5
        raise if asset.image_width != media_file.width
        raise if asset.image_height != media_file.height
        raise if asset.file_size != media_file.file_size
        raise if asset.file_ext != media_file.file_ext.to_s

        asset.variants.each do |variant|
          f = variant.open_file
          raise if f.is_corrupt?
          f.close
        end

        hash = { id: asset.id, md5: asset.md5 }.to_json
        puts hash
      rescue RuntimeError => e
        hash = {
          asset: {
            id: asset.id,
            md5: asset.md5,
            width: asset.image_width,
            height: asset.image_height,
            size: asset.file_size,
            ext: asset.file_ext,
          },
          media_file: media_file.as_json.except("metadata"),
          error: e.to_s,
        }
        STDERR.puts hash.to_json
      rescue StandardError => e
        hash = { id: asset.id, error: e.to_s }
        STDERR.puts hash.to_json

      ensure
        media_file&.close
      end
    end

    # Usage: bin/rails danbooru:images:populate_metadata
    task populate_metadata: :environment do
      sm = StorageManager::Local.new(base_url: "/", base_dir: ENV.fetch("DIR", Rails.root.join("public/data")))

      MediaMetadata.joins(:media_asset).where(metadata: {}).find_each do |metadata|
        asset = metadata.media_asset
        media_file = asset.variant(:original).open_file

        metadata.update!(metadata: media_file.metadata)
        puts "metadata[id=#{metadata.id}, md5=#{asset.md5}]: #{media_file.metadata.count}"
      rescue StandardError => e
        puts "error[id=#{metadata.id}]: #{e}"
      end
    end

    desc "Backup images to an archive file. Usage: bin/rails danbooru:images:backup > danbooru-images.tar"
    task backup: :environment do
      manager = Danbooru.config.storage_manager
      raise "Can't backup images since images aren't stored locally. Backup your images manually." if !manager.is_a?(StorageManager::Local)

      system(*%W[tar -cvC #{manager.base_dir} .])
    end

    desc "Restore images from backup. Usage: bin/rails danbooru:images:restore < danbooru-images.tar"
    task restore: :environment do
      manager = Danbooru.config.storage_manager
      raise "Can't restore images since images aren't stored locally. Restore your images manually." if !manager.is_a?(StorageManager::Local)

      system(*%W[tar -xv -C #{manager.base_dir}])
    end
  end

  namespace :docker do
    # Usage: bin/rails danbooru:docker:build
    #
    # Build a Docker image. Note that uncommited changes won't be included in the image; commit changes to Git first before building the image.
    desc "Build a Docker image"
    task :build do
      system("git archive HEAD | docker buildx build - --platform linux/amd64 --build-arg SOURCE_COMMIT=$(git rev-parse HEAD) --target development --tag ghcr.io/aibooruorg/aibooru:development --tag:x86-development --file Dockerfile --load")
      system("git archive HEAD | docker buildx build - --platform linux/amd64 --build-arg SOURCE_COMMIT=$(git rev-parse HEAD) --target production --tag ghcr.io/aibooruorg/aibooru --tag ghcr.io/aibooruorg/aibooru:x86 --file Dockerfile --load")
    end

    # Usage: bin/rails danbooru:docker:build-arm
    #
    # Build a Docker image for ARM. You may need to install QEMU first if building on x86.
    #
    # * sudo apt-get install qemu binfmt-support qemu-user-static       # Install QEMU
    # * docker run --rm -it --platform linux/arm64 ubuntu               # Test that QEMU works
    # * docker run --rm -it --platform linux/arm64 danbooru:arm -- bash # Test that the Danbooru image works
    desc "Build a Docker image for ARM"
    task :"build-arm" do
      system("git archive HEAD | docker buildx build - --platform linux/arm64 --build-arg SOURCE_COMMIT=$(git rev-parse HEAD) --target development --tag danbooru:development --tag danbooru:arm-development --file Dockerfile --load")
      system("git archive HEAD | docker buildx build - --platform linux/arm64 --build-arg SOURCE_COMMIT=$(git rev-parse HEAD) --target production --tag danbooru --tag danbooru:arm --file Dockerfile --load")
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

  namespace :database do
    desc "Backup the database to a file. Usage: bin/rails danbooru:database:backup > danbooru-backup.pg_dump"
    task backup: :environment do
      postgres_url = ActiveRecord::Base.configurations.find_db_config(Rails.env).url
      STDERR.puts "pg_dumpall --clean --if-exists --verbose --dbname #{postgres_url}"
      system(*%W[pg_dumpall --clean --if-exists --verbose --dbname #{postgres_url}])
    end

    desc "Restore the database from a backup. Usage: bin/rails danbooru:database:restore < danbooru-backup.pg_dump"
    task restore: :environment do
      postgres_url = ActiveRecord::Base.configurations.find_db_config(Rails.env).url
      STDERR.puts "psql --echo-all #{postgres_url}"
      system(*%W[psql --echo-all #{postgres_url}])
    end
  end
end
