#!/usr/bin/env ruby
#
# This script populates the database with random data for testing or development purposes.
#
# Usage: POSTS=100 bin/rails runner db/populate.rb

# The number of random posts to generate. By default, we generate 100 random
# posts and scale the size of other tables based on the number of posts.
POSTS = ENV.fetch("POSTS", 100).to_i

USERS        = ENV.fetch("USERS",        POSTS * 0.2).to_i
NOTES        = ENV.fetch("NOTES",        POSTS * 0.1).to_i
ARTISTS      = ENV.fetch("ARTISTS",      POSTS * 0.1).to_i
ALIASES      = ENV.fetch("ALIASES",      POSTS * 0.1).to_i
IMPLICATIONS = ENV.fetch("IMPLICATIONS", POSTS * 0.1).to_i
POOLS        = ENV.fetch("POOLS",        POSTS * 0.1).to_i
TOPICS       = ENV.fetch("TOPICS",       POSTS * 0.1).to_i
WIKI_PAGES   = ENV.fetch("WIKI_PAGES",   POSTS * 0.1).to_i
COMMENTS     = ENV.fetch("COMMENTS",     POSTS * 0.2).to_i
COMMENTARIES = ENV.fetch("COMMENTARIES", POSTS * 0.5).to_i
FAVORITES    = ENV.fetch("FAVORITES",    POSTS * 5.0).to_i

# The default password for all user accounts. The default is `password`.
DEFAULT_PASSWORD = ENV.fetch("DEFAULT_PASSWORD", "password")

CurrentUser.user = User.system
CurrentUser.ip_addr = "127.0.0.1"

def populate_users(n, password: DEFAULT_PASSWORD)
  puts "*** Creating users ***"

  User::Levels.constants.without(:ANONYMOUS).each do |level|
    user = User.create(name: level.to_s.downcase, password: password, password_confirmation: password, level: User::Levels.const_get(level))
    puts "Created user ##{user.id} (#{user.name})"
  end

  user = User.create(name: "contributor", password: password, password_confirmation: password, level: User::Levels::BUILDER, can_upload_free: true)
  puts "Created user ##{user.id} (#{user.name})"

  user = User.create(name: "approver", password: password, password_confirmation: password, level: User::Levels::BUILDER, can_upload_free: true, can_approve_posts: true)
  puts "Created user ##{user.id} (#{user.name})"

  n.times do |i|
    user = User.create(name: FFaker::Internet.user_name, password: password, password_confirmation: password, level: User::Levels::MEMBER)
    puts "Created user ##{user.id}"
  end
end

def populate_posts(n, search: "rating:s", batch_size: 200, timeout: 30.seconds)
  puts "*** Creating posts ***"

  # Generate posts in batches of 200 (by default)
  n.times.each_slice(batch_size).map(&:size).each do |count|
    posts = Danbooru::Http.get("https://danbooru.donmai.us/posts.json?tags=#{search}+random:#{count}&limit=#{count}").parse

    posts.each do |danbooru_post|
      Timeout.timeout(timeout) do
        user = User.order("random()").first
        ip_addr = FFaker::Internet.ip_v4_address
        upload = Upload.create(uploader: user, uploader_ip_addr: ip_addr, source: danbooru_post["file_url"])
        sleep 1 until upload.reload.is_finished? # wait for the job worker to process the upload in the background

        post = Post.new_from_upload(upload.upload_media_assets.first, tag_string: danbooru_post["tag_string"], source: danbooru_post["source"], rating: danbooru_post["rating"])
        post.save

        puts "Created post ##{post.id}"
      end
    rescue
      # ignore errors
    end
  end
end

def populate_comments(n)
  puts "*** Creating comments ***"

  n.times do |i|
    user = User.order("random()").first
    post = Post.order("random()").first
    ip_addr = FFaker::Internet.ip_v4_address
    comment = CurrentUser.scoped(user) { Comment.create(creator: user, creator_ip_addr: ip_addr, post: post, body: FFaker::Lorem.paragraph) }

    puts "Created comment ##{comment.id}"
  end
end

def populate_commentaries(n)
  puts "*** Creating artist commentaries ***"

  n.times do |i|
    user = User.order("random()").first
    post = Post.order("random()").first
    artcomm = CurrentUser.scoped(user) { ArtistCommentary.create(post: post, original_title: FFaker::Lorem.sentence, original_description: FFaker::Lorem.paragraphs.join("\n\n")) }

    puts "Created commentary ##{artcomm.id}"
  end
end

def populate_notes(n)
  puts "*** Creating notes ***"

  n.times do |i|
    user = User.order("random()").first
    post = Post.order("random()").first
    x = rand(post.image_width).clamp(0..post.image_width - 100)
    y = rand(post.image_height).clamp(0..post.image_height - 100)
    w = rand(post.image_width - x).clamp(100..post.image_width)
    h = rand(post.image_height - y).clamp(100..post.image_height)

    note = Note.create(post: post, x: x, y: y, width: w, height: h, body: FFaker::Lorem.paragraph)

    puts "Created note ##{note.id}"
  end
end

def populate_artists(n)
  puts "*** Creating artists ***"

  n.times do |i|
    url_string = rand(5).times.map { FFaker::Internet.http_url }.join("\n")
    artist = Artist.create(name: FFaker::Internet.user_name, url_string: url_string)

    puts "Created artist ##{artist.id}"
  end
end

def populate_aliases(n)
  puts "*** Creating tag aliases ***"

  n.times do |i|
    tag_alias = TagAlias.create(antecedent_name: FFaker::Internet.user_name, consequent_name: FFaker::Internet.user_name)
    puts "Created tag alias ##{tag_alias.id}"
  end
end

def populate_implications(n)
  puts "*** Creating tag implications ***"

  n.times do |i|
    tag_implication = TagImplication.create(antecedent_name: FFaker::Internet.user_name, consequent_name: FFaker::Internet.user_name)
    puts "Created tag implication ##{tag_implication.id}"
  end
end

def populate_pools(n, posts_per_pool: 20)
  puts "*** Creating pools ***"

  n.times do |i|
    posts = Post.order("random()").take(rand(posts_per_pool))
    pool = Pool.create(name: FFaker::Lorem.sentence, description: FFaker::Lorem.paragraph, post_ids: posts.pluck(:id))
    puts "Created pool ##{pool.id}"
  end
end

def populate_favorites(n)
  puts "*** Creating pools ***"

  n.times do |i|
    user = User.order("random()").first
    post = Post.order("random()").first
    favorite = Favorite.create(user: user, post: post)

    puts "Created favorite ##{favorite.id}"
  end
end

def populate_wiki_pages(n)
  puts "*** Creating wiki pages ***"

  n.times do |i|
    user = User.order("random()").first
    other_names = rand(5).times.map { FFaker::Internet.user_name }
    wiki = CurrentUser.scoped(user) { WikiPage.create(title: FFaker::Internet.user_name, other_names: other_names, body: FFaker::Lorem.paragraphs.join("\n\n")) }

    puts "Created wiki ##{wiki.id}"
  end
end

def populate_forum(n, posts_per_topic: 20)
  puts "*** Creating forum topics ***"

  n.times do |i|
    user = User.order("random()").first
    topic = CurrentUser.scoped(user) { ForumTopic.create(creator: user, title: FFaker::Lorem.sentence, original_post_attributes: { creator: user, body: FFaker::Lorem.paragraphs.join("\n\n") }) }

    rand(posts_per_topic).times do
      user = User.order("random()").first
      CurrentUser.scoped(user) { ForumPost.create(creator: user, topic: topic, body: FFaker::Lorem.paragraphs.join("\n\n")) }
    end

    puts "Created topic ##{topic.id}"
  end
end

populate_users(USERS)
populate_posts(POSTS)
populate_notes(NOTES)
populate_artists(ARTISTS)
populate_aliases(ALIASES)
populate_implications(IMPLICATIONS)
populate_pools(POOLS)
populate_forum(TOPICS)
populate_wiki_pages(WIKI_PAGES)
populate_comments(COMMENTS)
populate_commentaries(COMMENTARIES)
populate_favorites(FAVORITES)
