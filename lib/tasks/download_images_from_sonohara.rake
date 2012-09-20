desc "Download all images from sonohara.donmai.us"
task :download_images_from_sonohara => :environment do
  Post.order("id desc").limit(1000).each do |post|
    `cd /var/www/danbooru/current/public/data && wget http://sonohara.donmai.us/data/#{post.md5}.#{post.file_ext}`
    `cd /var/www/danbooru/current/public/data/preview && wget http://sonohara.donmai.us/data/preview/#{post.md5}.jpg`
    `cd /var/www/danbooru/current/public/data/sample && wget http://sonohara.donmai.us/data/sample/sample-#{post.md5}.jpg`
  end
end
