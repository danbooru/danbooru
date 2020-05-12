require 'set'

CurrentUser.ip_addr = "127.0.0.1"
Delayed::Worker.delay_jobs = false
used_names = Set.new([""])

def rand_string(n, unique = false)
  string = ""

  n = rand(n) + 1

  while used_names.include?(string)
    consonants = "bcdfghjklmnpqrstvwxz".scan(/./)
    vowels = "aeiouy".scan(/./)
    string = ""
    n.times do
      string << consonants[rand(consonants.size)]
      string << vowels[rand(vowels.size)]
    end
    return string unless unique
  end

  used_names.add(string)
  string
end

def rand_sentence(n, unique = false)
  (0..n).map {rand_string(n, unique)}.join(" ") + "."
end

def rand_paragraph(n, unique = false)
  (0..n).map {rand_sentence(n, unique)}.join(" ")
end

def rand_document(n, unique = false)
  (0..n).map {rand_paragraph(n, unique)}.join("\n\n")
end

if User.count == 0
  puts "Creating users"

  begin
    user = User.create(
      :name => "admin",
      :password => "password1",
      :password_confirmation => "password1"
    )

    CurrentUser.user = user
    User::Levels.constants.reject { |x| x == :ADMIN }.each do |level|
      newuser = User.create(
        name: level.to_s.downcase,
        password: "password1",
        password_confirmation: "password1"
      )
      newuser.promote_to!(User::Levels.const_get(level), :is_upgrade => true, :skip_dmail => true)
    end

    newuser = User.create(
      :name => "banned",
      :password => "password1",
      :password_confirmation => "password1"
    )
    Ban.create(:user_id => newuser.id, :reason => "from the start", :duration => 99999)

    newuser = User.create(
      :name => "uploader",
      :password => "password1",
      :password_confirmation => "password1"
    )
    newuser.promote_to!(User::Levels::BUILDER, :can_upload_free => true, :is_upgrade => true, :skip_dmail => true)

    newuser = User.create(
      :name => "approver",
      :password => "password1",
      :password_confirmation => "password1"
    )
    newuser.promote_to!(User::Levels::BUILDER, :can_approve_posts => true, :is_upgrade => true, :skip_dmail => true)
  end

  0.upto(10) do |i|
    User.create(
      :name => rand_string(8, true),
      :password => "password1",
      :password_confirmation => "password1"
    )
  end
  used_names = Set.new([""])
else
  puts "Skipping users"
  user = User.find_by_name("albert")
end

CurrentUser.user = User.admins.first
CurrentUser.ip_addr = "127.0.0.1"

if Upload.count == 0
  puts "Creating uploads"
  1.upto(50) do |i|
    color1 = rand(4096).to_s(16)
    color2 = rand(4096).to_s(16)
    width = rand(100..2099)
    height = (width * (rand(0.5) + 1)).to_i
    url = "http://ipsumimage.appspot.com/#{width}x#{height},#{color1}"
    tags = rand(1_000_000_000).to_s.scan(/../).join(" ")
    puts url
    service = UploadService.new(source: url, tag_string: tags, rating: "s")
    service.start!
  end
else
  puts "Skipping uploads"
end

if Comment.count == 0
  puts "Creating comments"
  Post.all.each do |post|
    rand(100).times do
      Comment.create(:post_id => post.id, :body => rand_paragraph(6))
    end
  end
else
  puts "Skipping comments"
end

if Note.count == 0
  puts "Creating notes"
  Post.order("random()").limit(10).each do |post|
    rand(5).times do
      note = Note.create(:post_id => post.id, :x => rand(post.image_width), :y => rand(post.image_height), :width => 100, :height => 100, :body => Time.now.to_f.to_s)

      rand(20).times do |i|
        note.update(body: rand_sentence(6))
      end
    end
  end
else
  puts "Skipping notes"
end

if Artist.count == 0
  puts "Creating artists"
  20.times do |i|
    Artist.create(:name => rand_string(9, true))
  end
  used_names = Set.new([""])
else
  puts "Skipping artists"
end

if TagAlias.count == 0
  puts "Creating tag aliases"

  20.times do |i|
    TagAlias.create(:antecedent_name => rand_string(9, true), :consequent_name => rand_string(9, true))
  end
  used_names = Set.new([""])
else
  puts "Skipping tag aliases"
end

if TagImplication.count == 0
  puts "Creating tag implictions"

  20.times do |i|
    TagImplication.create(:antecedent_name => rand_string(9, true), :consequent_name => rand_string(9, true))
  end
  used_names = Set.new([""])
else
  puts "Skipping tag implications"
end

if Pool.count == 0
  puts "Creating pools"

  1.upto(20) do |i|
    pool = Pool.create(:name => rand_string(9, true))
    rand(33).times do |j|
      pool.add!(Post.order("random()").first)
    end
  end
  used_names = Set.new([""])
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

  20.times do |i|
    topic = ForumTopic.create(:title => rand_sentence(6))

    rand(100).times do |j|
      post = ForumPost.create(:topic_id => topic.id, :body => rand_document(6))
    end
  end
end
