if User.count == 0
  puts "Creating users"
  user = User.create(
    :name => "albert",
    :password => "password1",
    :password_confirmation => "password1"
  )
  
  0.upto(100) do |i|
    User.create(
      :name => i.to_s * 5,
      :password => i.to_s * 5,
      :password_confirmation => i.to_s * 5
    )
  end
else
  puts "Skipping users"
  user = User.first
end

CurrentUser.user = user
CurrentUser.ip_addr = "127.0.0.1"

if Upload.count == 0
  puts "Creating uploads"
  1.upto(100) do |i|
    url = "http://dummyimage.com/#{i * 10}x400/000/fff"
    tags = (i * i * i).to_s.scan(/./).uniq.join(" ")
  
    Upload.create(:source => url, :content_type => "image/gif", :rating => "q", :tag_string => tags)
  end
else
  puts "Skipping uploads"
end

if Post.count == 0
  puts "Creating posts"
  Upload.all.each do |upload|
    upload.process!
  end
else
  puts "Skipping posts"
end

if Comment.count == 0
  puts "Creating comments"
  Post.all.each do |post|
    Comment.create(:post_id => post.id, :body => rand(1_000_000).to_s)
  end
else
  puts "Skipping comments"
end

if Note.count == 0
  puts "Creating notes"
  Post.all.each do |post|
    3.times do
      Note.create(:post_id => post.id, :x => 0, :y => 0, :width => 100, :height => 100, :body => rand(1_000_000).to_s)
    end
  end
else
  puts "Skipping notes"
end

if Artist.count == 0
  puts "Creating artists"
  0.upto(100) do |i|
    Artist.create(:name => i.to_s)
  end
else
  puts "Skipping artists"
end

if TagAlias.count == 0
  puts "Creating tag aliases"
  
  100.upto(199) do |i|
    TagAlias.create(:antecedent_name => i.to_s, :consequent_name => (i * 100).to_s)
  end
else
  puts "Skipping tag aliases"
end

if TagImplication.count == 0
  puts "Creating tag implictions"

  100_000.upto(100_100) do |i|
    TagImplication.create(:antecedent_name => i.to_s, :consequent_name => (i * 100).to_s)
  end
else
  puts "Skipping tag implications"
end

if Pool.count == 0
  puts "Creating pools"
  
  1.upto(20) do |i|
    pool = Pool.create(:name => i.to_s)
    33.times do |j|
      pool.add!(Post.order("random()").first)
    end
  end
end

if Favorite.count == 0
  puts "Creating favorites"

  Post.order("random()").limit(50).each do |post|
    user = User.order("random()").first
    post.add_favorite!(user)
    post.add_favorite!(CurrentUser.user)
  end
else 
  puts "Skipping favorites"
end

if TagSubscription.count == 0
  puts "Creating tag subscriptions"
  TagSubscription.create(:name => "0", :tag_query => Tag.order("random()").first.name)
  1.upto(50) do |i|
    CurrentUser.user = User.order("random()").first
    TagSubscription.create(:name => i.to_s, :tag_query => Tag.order("random()").first.name)
  end
else
  puts "Skipping tag subscriptions"
end

