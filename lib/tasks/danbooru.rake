# This file contains commands for running various routine maintenance tasks on
# a Danbooru instance. Run `bin/rails -T` to see a list of all available tasks.
#
# @see https://guides.rubyonrails.org/command_line.html#rake
# @see https://guides.rubyonrails.org/command_line.html#custom-rake-tasks
namespace :danbooru do
  # Usage: bin/rails danbooru:cron
  desc "Run the cronjob scheduler"
  task cron: :environment do
    Clockwork::run
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

      MediaAsset.active.parallel_each(in_processes: processes) do |asset|
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

    # Usage: TAGS="touhou" bin/rails danbooru:images:backup
    desc "Backup images"
    task backup: :environment do
      CurrentUser.user = User.system
      sm = Danbooru.config.backup_storage_manager
      tags = ENV["TAGS"]
      posts = Post.system_tag_match(tags)

      posts.parallel_each do |post|
        sm.store_file(post.file(:preview), post, :preview) if post.has_preview?
        sm.store_file(post.file(:sample), post, :sample) if post.has_large?
        sm.store_file(post.file(:original), post, :original)
      end
    end
  end

  namespace :docker do
    # Usage: bin/rails danbooru:docker:build
    #
    # Build a Docker image. Note that uncommited changes won't be included in the image; commit changes to Git first before building the image.
    desc "Build a Docker image"
    task :build do
      system("git archive HEAD | docker buildx build - --platform linux/amd64 --build-arg SOURCE_COMMIT=$(git rev-parse HEAD) --tag danbooru --tag danbooru:x86 --file Dockerfile --load")
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
      system("git archive HEAD | docker buildx build - --platform linux/arm64 --build-arg SOURCE_COMMIT=$(git rev-parse HEAD) --tag danbooru --tag danbooru:arm --file Dockerfile --load")
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
end
