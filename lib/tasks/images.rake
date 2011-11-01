namespace :images do
  desc "Generate medium-sized images of posts"
  task :generate_medium => :environment do
    Post.where("width > ?", Danbooru.config.medium_image_width).find_each do |post|
      if post.is_image?
        puts "resizing medium #{post.id}"
        Danbooru.resize(post.file_path, post.medium_file_path, Danbooru.config.medium_image_width, nil, 90)
      end
    end
  end

  desc "Generate large-sized images of posts"
  task :generate_large => :environment do
    Post.where("width > ?", Danbooru.config.large_image_width).find_each do |post|
      if post.is_image?
        puts "resizing large #{post.id}"
        Danbooru.resize(post.file_path, post.large_file_path, Danbooru.config.large_image_width, nil, 90)
      end
    end
  end
  
  desc "Distribute medium posts to other servers"
  task :distribute_medium => :environment do
    Post.where("width > ?", Danbooru.config.medium_image_width).find_each do |post|
      if post.is_image?
        puts "distributing medium #{post.id}"
        RemoteFileManager.new(post.medium_file_path).distribute
      end
    end
  end

  desc "Distribute large posts to other servers"
  task :distribute_large => :environment do
    Post.where("width > ?", Danbooru.config.large_image_width).find_each do |post|
      if post.is_image?
        puts "distributing large #{post.id}"
        RemoteFileManager.new(post.large_file_path).distribute
      end
    end
  end
end

