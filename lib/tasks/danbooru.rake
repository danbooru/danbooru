require "newrelic_rpm"
require "tasks/newrelic"

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
  # Schedules all posts to be reindexed in IQDB. Requires the delayed jobs
  # worker (bin/delayed_job) to be running.
  desc "Reindex all posts in IQDB"
  task reindex_iqdb: :environment do
    Post.find_each do |post|
      puts "post ##{post.id}"
      post.update_iqdb
    end
  end

  # Usage: TAGS="touhou" bin/rails danbooru:images:validate
  #
  # Check whether any images are missing, corrupt, or don't match the
  # width/height/size/ext metadata in the database.
  namespace :images do
    task validate: :environment do
      processes = ENV.fetch("PROCESSES", Etc.nprocessors).to_i
      posts = Post.system_tag_match(ENV["TAGS"]).reorder(nil)

      posts.parallel_each(in_processes: processes) do |post|
        media_file = MediaFile.open(post.file(:original))

        raise if post.md5 != media_file.md5
        raise if post.image_width != media_file.width
        raise if post.image_height != media_file.height
        raise if post.file_size != media_file.file_size
        raise if post.file_ext != media_file.file_ext.to_s

        puts "post ##{post.id}"
      rescue RuntimeError => e
        hash = {
          post: {
            id: post.id,
            md5: post.md5,
            width: post.image_width,
            height: post.image_height,
            size: post.file_size,
            ext: post.file_ext,
          },
          media_file: media_file.as_json.except("metadata"),
          error: e.to_s,
        }
        STDERR.puts hash.to_json
      rescue StandardError => e
        hash = { id: post.id, md5: post.md5, error: e.to_s }
        STDERR.puts hash.to_json
      end
    end

    # Usage: bin/rails danbooru:images:populate_metadata
    task populate_metadata: :environment do
      sm = StorageManager::Local.new(base_url: "/", base_dir: ENV.fetch("DIR", Rails.root.join("public/data")))

      MediaMetadata.joins(:media_asset).where(metadata: {}).find_each do |metadata|
        asset = metadata.media_asset
        file = sm.open(sm.file_path(asset.md5, asset.file_ext, :original))
        media_file = MediaFile.open(file)

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
        sm.store_file(post.file(:crop), post, :crop) if post.has_cropped?
        sm.store_file(post.file(:sample), post, :sample) if post.has_large?
        sm.store_file(post.file(:original), post, :original)
      end
    end
  end

  namespace :docker do
    # Usage: bin/rails danbooru:docker:build
    #
    # Build a Docker image. Note that uncommited changes won't be included in
    # the image; commit changes first before building the image.
    desc "Build a Docker image based on latest commit"
    task :build do
      system("git archive HEAD | docker buildx build - --build-arg SOURCE_COMMIT=$(git rev-parse HEAD) -t danbooru -f Dockerfile")
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
