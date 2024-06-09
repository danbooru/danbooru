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

  namespace :images do
    desc 'Reindex posts in IQDB. Usage: COND="created_at > \'2024-01-01\'" DRY_RUN=false bin/rails danbooru:images:reindex_iqdb'
    task reindex_iqdb: :environment do
      condition = ENV.fetch("COND", "TRUE")
      dry_run = ENV.fetch("DRY_RUN", "false").truthy?

      if dry_run
        STDERR.puts "Not making any changes. Do `DRY_RUN=false bin/rails danbooru:images:reindex_iqdb` to reindex the posts."
      end

      Post.where(condition).parallel_find_each do |post|
        puts "post ##{post.id}"
        post.update_iqdb unless dry_run
      end
    end

    desc 'Regenerate metadata for media assets. Usage: COND="created_at > \'2024-01-01\'" DRY_RUN=false bin/rails danbooru:images:regenerate_metadata'
    task regenerate_metadata: :environment do
      CurrentUser.user = User.system
      condition = ENV.fetch("COND", "TRUE")
      dry_run = ENV.fetch("DRY_RUN", "true").truthy?

      if dry_run
        STDERR.puts "Not making any changes. Do `DRY_RUN=false bin/rails danbooru:images:regenerate_metadata` to actually update the metadata."
      end

      MediaAsset.active.where(condition).parallel_find_each do |asset|
        variant = asset.variant(:original)
        media_file = variant.open_file

        if media_file.nil?
          puts ({ id: asset.id, error: "file doesn't exist", path: variant.file_path }).to_json
          next
        end

        # Setting `file` updates the metadata if it's different.
        asset.file = media_file
        asset.media_metadata.file = media_file
        asset.post.assign_attributes(image_width: asset.image_width, image_height: asset.image_height, file_ext: asset.file_ext, file_size: asset.file_size) if asset.post.present?

        old = asset.media_metadata.metadata_was.to_h
        new = asset.media_metadata.metadata.to_h
        metadata_changes = { added_metadata: (new.to_a - old.to_a).to_h, removed_metadata: (old.to_a - new.to_a).to_h }.compact_blank
        puts ({ id: asset.id, **asset.changes, **metadata_changes }).to_json

        unless dry_run
          asset.post.save! if asset.post&.changed?
          asset.save! if asset.changed?
          asset.media_metadata.save! if asset.media_metadata.changed?
        end

        media_file.close
      end
    end

    task validate: :environment do
      MediaAsset.active.parallel_find_each do |asset|
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
