namespace :images do
  desc "Regenerates all images for a post id"
  task :regen => :environment do
    post_id = ENV["id"]

    if post_id !~ /\d+/
      raise "Usage: regen id=n"
    end

    post = Post.find(post_id)
    upload = Upload.new
    upload.file_ext = post.file_ext
    upload.image_width = post.image_width
    upload.image_height = post.image_height
    upload.md5 = post.md5
    upload.generate_resizes(post.file_path)
    post.distribute_files
  end

  desc "Generate thumbnail-sized images of posts"
  task :generate_preview => :environment do
    width = 150
    post_id = ENV["id"]

    if post_id !~ /\d+/
      raise "Usage: generate_preview id=n"
    end

    Post.where(id: post_id).find_each do |post|
      if post.is_image?
        puts "resizing preview #{post.id}"
        DanbooruImageResizer.resize(post.file_path, post.preview_file_path, width, width, 90)
      end
    end
  end

  desc "Generate large-sized images of posts"
  task :generate_large => :environment do
    post_id = ENV["id"]

    if post_id !~ /\d+/
      raise "Usage: generate_large id=n"
    end

    Post.where(id: post_id).find_each do |post|
      if post.is_image? && post.has_large?
        puts "resizing large #{post.id}"
        DanbooruImageResizer.resize(post.file_path, post.large_file_path, Danbooru.config.large_image_width, nil, 90)
        post.distribute_files
      end
    end
  end
end
