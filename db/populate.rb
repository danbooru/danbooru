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
FEEDBACKS    = ENV.fetch("FEEDBACKS",    USERS * 0.5).to_i
BANS         = ENV.fetch("BANS",         USERS * 0.1).to_i

# The default password for all user accounts. The default is `password`.
DEFAULT_PASSWORD = ENV.fetch("DEFAULT_PASSWORD", "password")

CurrentUser.user = User.system

def populate_users(n, password: DEFAULT_PASSWORD)
  Rails.logger.info "*** Creating users ***"

  User::Levels.constants.without(:ANONYMOUS).each do |level|
    user = User.create(name: "#{level.to_s.downcase}_user", password: password, password_confirmation: password, level: User::Levels.const_get(level))
    Rails.logger.info "Created user ##{user.id} (#{user.name})"
  end

  n.times do
    user = User.create(name: Faker::Internet.unique.username, password: password, password_confirmation: password, level: User::Levels::MEMBER)
    Rails.logger.info "Created user ##{user.id}"
  end
end

def populate_posts(n, search: "rating:s", batch_size: 200, timeout: 30.seconds)
  Rails.logger.info "*** Creating posts ***"

  # Generate posts in batches of 200 (by default)
  n.times.each_slice(batch_size).map(&:size).each do |count|
    posts = Danbooru::Http.get("https://danbooru.donmai.us/posts.json?tags=#{search}+random:#{count}&limit=#{count}").parse

    posts.each do |danbooru_post|
      Timeout.timeout(timeout) do
        user = User.order("random()").first
        upload = Upload.create(uploader: user, source: danbooru_post["file_url"])
        sleep 1 until upload.reload.is_finished? # wait for the job worker to process the upload in the background

        post = Post.new_from_upload(upload.upload_media_assets.first, tag_string: danbooru_post["tag_string"], source: danbooru_post["source"], rating: danbooru_post["rating"])
        post.save

        Rails.logger.info "Created post ##{post.id}"
      end
    rescue StandardError
      # ignore errors
    end
  end
end

def populate_comments(n)
  Rails.logger.info "*** Creating comments ***"

  n.times do
    user = User.order("random()").first
    post = Post.order("random()").first
    comment = CurrentUser.scoped(user) { Comment.create(creator: user, post: post, body: Faker::Lorem.paragraph) }

    Rails.logger.info "Created comment ##{comment.id}"
  end
end

def populate_commentaries(n)
  Rails.logger.info "*** Creating artist commentaries ***"

  n.times do
    user = User.order("random()").first
    post = Post.order("random()").first
    artcomm = CurrentUser.scoped(user) { ArtistCommentary.create(post: post, original_title: Faker::Lorem.sentence, original_description: Faker::Lorem.paragraphs.join("\n\n")) }

    Rails.logger.info "Created commentary ##{artcomm.id}"
  end
end

def populate_notes(n)
  Rails.logger.info "*** Creating notes ***"

  n.times do
    user = User.order("random()").first
    post = Post.order("random()").first
    x = rand(post.image_width).clamp(0..post.image_width - 100)
    y = rand(post.image_height).clamp(0..post.image_height - 100)
    w = rand(post.image_width - x).clamp(100..post.image_width)
    h = rand(post.image_height - y).clamp(100..post.image_height)

    note = Note.create(post: post, x: x, y: y, width: w, height: h, body: Faker::Lorem.paragraph)

    Rails.logger.info "Created note ##{note.id}"
  end
end

def populate_artists(n)
  Rails.logger.info "*** Creating artists ***"

  n.times do
    url_string = rand(5).times.map { Faker::Internet.url }.join("\n")
    artist = Artist.create(name: Faker::Internet.unique.username, url_string: url_string)

    Rails.logger.info "Created artist ##{artist.id}"
  end
end

def populate_aliases(n)
  Rails.logger.info "*** Creating tag aliases ***"

  n.times do
    tag_alias = TagAlias.create(antecedent_name: Faker::Internet.unique.username, consequent_name: Faker::Internet.unique.username)
    Rails.logger.info "Created tag alias ##{tag_alias.id}"
  end
end

def populate_implications(n)
  Rails.logger.info "*** Creating tag implications ***"

  n.times do
    tag_implication = TagImplication.create(antecedent_name: Faker::Internet.unique.username, consequent_name: Faker::Internet.unique.username)
    Rails.logger.info "Created tag implication ##{tag_implication.id}"
  end
end

def populate_pools(n, posts_per_pool: 20)
  Rails.logger.info "*** Creating pools ***"

  n.times do
    posts = Post.order("random()").take(rand(posts_per_pool))
    pool = Pool.create(name: Faker::Lorem.sentence, description: Faker::Lorem.paragraph, post_ids: posts.pluck(:id))
    Rails.logger.info "Created pool ##{pool.id}"
  end
end

def populate_favorites(n)
  Rails.logger.info "*** Creating pools ***"

  n.times do
    user = User.order("random()").first
    post = Post.order("random()").first
    favorite = Favorite.create(user: user, post: post)

    Rails.logger.info "Created favorite ##{favorite.id}"
  end
end

def populate_feedbacks(n)
  Rails.logger.info "*** Creating feedbacks ***"

  # Generate feedbacks
  n.times do
    user = User.order("random()").first
    creator = User.where.not(id: user.id).order("random()").first
    created_at = Faker::Time.between(from: 1.year.ago, to: Time.zone.now)

    feedback = UserFeedback.create(user: user, creator: creator, category: %w[positive negative neutral].sample, body: Faker::Lorem.paragraph, created_at: created_at)

    Rails.logger.info "Created feedback ##{feedback.id}"
  end
end

def populate_bans(n)
  Rails.logger.info "*** Creating bans ***"

  # Generate bans
  n.times do
    creator = User.where(level: User::Levels::MODERATOR..).order("random()").first
    recipient = User.where(level: ..User::Levels::APPROVER).order("random()").first
    duration = [1.day, 1.week, 1.year, 100.years].sample
    created_at = Faker::Time.between(from: 1.year.ago, to: Time.zone.now)

    ban = Ban.create(banner: creator, user: recipient, duration: duration, reason: Faker::Lorem.sentence, created_at: created_at)

    Rails.logger.info "Created ban ##{ban.id}"
  end
end

def populate_wiki_pages(n)
  Rails.logger.info "*** Creating wiki pages ***"

  n.times do
    user = User.order("random()").first
    other_names = rand(5).times.map { Faker::Internet.unique.username }
    wiki = CurrentUser.scoped(user) { WikiPage.create(title: Faker::Internet.unique.username, other_names: other_names, body: Faker::Lorem.paragraphs.join("\n\n")) }

    Rails.logger.info "Created wiki ##{wiki.id}"
  end
end

def populate_forum(n, posts_per_topic: 20)
  Rails.logger.info "*** Creating forum topics ***"

  n.times do
    user = User.order("random()").first
    topic = CurrentUser.scoped(user) { ForumTopic.create(creator: user, title: Faker::Lorem.sentence, original_post_attributes: { creator: user, body: Faker::Lorem.paragraphs.join("\n\n") }) }

    rand(posts_per_topic).times do
      user = User.order("random()").first
      CurrentUser.scoped(user) { ForumPost.create(creator: user, topic: topic, body: Faker::Lorem.paragraphs.join("\n\n")) }
    end

    Rails.logger.info "Created topic ##{topic.id}"
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
populate_feedbacks(FEEDBACKS)
populate_bans(BANS)
