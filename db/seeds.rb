if User.count == 0
  puts "Creating users"
  user = User.create(
    :name => "albert",
    :password => "password1",
    :password_confirmation => "password1"
  )
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
  
  11.upto(99) do |i|
    TagAlias.create(:antecedent_name => i.to_s, :consequent_name => (i * 100).to_s)
  end
else
  puts "Skipping tag aliases"
end

if TagImplication.count == 0
  puts "Creating tag implictions"

  10_000.upto(10_100) do |i|
    TagImplication.create(:antecedent_name => i.to_s, :consequent_name => (i * 100).to_s)
  end
else
  puts "Skipping tag implications"
end