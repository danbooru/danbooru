require 'set'

CurrentUser.ip_addr = "127.0.0.1"
Delayed::Worker.delay_jobs = false
$used_names = Set.new([""])

def rand_string(n)
  string = ""

  n = rand(n) + 1

  while $used_names.include?(string)
    consonants = "bcdfghjklmnpqrstvwxz".scan(/./)
    vowels = "aeiouy".scan(/./)
    string = ""
    n.times do
      string << consonants[rand(consonants.size)]
      string << vowels[rand(vowels.size)]
    end
  end

  $used_names.add(string)
  string
end

def rand_sentence(n)
  (0..n).map {rand_string(6)}.join(" ") + "."
end

def rand_paragraph(n)
  (0..n).map {rand_sentence(6)}.join(" ")
end

def rand_document(n)
  (0..n).map {rand_pargraph(6)}.join("\n\n")
end

if User.count == 0
  puts "Creating users"
  user = User.create(
    :name => "admin",
    :password => "password1",
    :password_confirmation => "password1"
  )

  0.upto(10) do |i|
    User.create(
      :name => rand_string(8),
      :password => i.to_s * 5,
      :password_confirmation => i.to_s * 5
    )
  end
else
  puts "Skipping users"
  user = User.find_by_name("albert")
end

CurrentUser.user = user

if Upload.count == 0
  puts "Creating uploads"
  1.upto(100) do |i|
    color1 = rand(4096).to_s(16)
    color2 = rand(4096).to_s(16)
    width = rand(2000) + 100
    height = rand(2000) + 100
    url = "http://ipsumimage.appspot.com/#{width}x#{height}"
    tags = rand_sentence(6).scan(/[a-z]+/).join(" ")

    Upload.create(:source => url, :content_type => "image/gif", :rating => "q", :tag_string => tags, :server => Socket.gethostname)
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
    rand(30).times do
      Comment.create(:post_id => post.id, :body => rand_paragraph(6))
    end
  end
else
  puts "Skipping comments"
end

if Note.count == 0
  puts "Creating notes"
  Post.all.each do |post|
    rand(10).times do
      note = Note.create(:post_id => post.id, :x => 0, :y => 0, :width => 100, :height => 100, :body => Time.now.to_f.to_s)

      rand(30).times do |i|
        note.update_attributes(:body => rand_sentence(6))
      end
    end
  end
else
  puts "Skipping notes"
end

if Artist.count == 0
  puts "Creating artists"
  0.upto(100) do |i|
    Artist.create(:name => rand_string(6))
  end
else
  puts "Skipping artists"
end

if TagAlias.count == 0
  puts "Creating tag aliases"

  100.upto(199) do |i|
    TagAlias.create(:antecedent_name => rand_string(6), :consequent_name => rand_string(6))
  end
else
  puts "Skipping tag aliases"
end

if TagImplication.count == 0
  puts "Creating tag implictions"

  100_000.upto(100_100) do |i|
    TagImplication.create(:antecedent_name => rand_string(6), :consequent_name => rand_string(6))
  end
else
  puts "Skipping tag implications"
end

if Pool.count == 0
  puts "Creating pools"

  1.upto(20) do |i|
    pool = Pool.create(:name => i.to_s)
    rand(33).times do |j|
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

if ForumTopic.count == 0
  puts "Creating forum posts"

  100.times do |i|
    topic = ForumTopic.create(:title => rand_sentence(6))

    rand(100).times do |j|
      post = ForumPost.create(:topic_id => topic.id, :body => rand_document(6))
    end
  end
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

