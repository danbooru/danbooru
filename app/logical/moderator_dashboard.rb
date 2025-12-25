# frozen_string_literal: true

class ModeratorDashboard
  attr_reader :min_date, :max_level

  def initialize(min_date: 1.week.ago.to_date, max_level: User::Levels::MEMBER)
    @min_date = min_date
    @max_level = max_level.to_i
  end

  def artists
    ArtistVersion
      .joins(:updater)
      .where("artist_versions.created_at > ?", min_date)
      .where("users.level <= ?", max_level)
      .group(:updater)
      .order(Arel.sql("count(*) desc"))
      .limit(10)
      .count
      .to_h
  end

  def comments
    CommentVote
      .joins(comment: [:creator])
      .where("comments.score < 0")
      .where("comment_votes.created_at > ?", min_date)
      .where("users.level <= ?", max_level)
      .group(:comment)
      .having("count(*) >= 3")
      .order(Arel.sql("count(*) desc"))
      .limit(10)
      .count
      .to_h
  end

  def mod_actions
    ModAction.visible(CurrentUser.user).includes(:creator).order("id desc").limit(10)
  end

  def notes
    NoteVersion
      .joins(:updater)
      .where("note_versions.created_at > ?", min_date)
      .where("users.level <= ?", max_level)
      .group(:updater)
      .order(Arel.sql("count(*) desc"))
      .limit(10)
      .count
      .to_h
  end

  def posts
    ::Post
      .joins(:uploader)
      .where("posts.created_at > ?", min_date)
      .where("users.level <= ?", max_level)
      .group(:uploader)
      .order(Arel.sql("count(*) desc"))
      .limit(10)
      .count
      .to_h
  end

  def user_feedbacks
    UserFeedback.visible(CurrentUser.user).includes(:user).order("id desc").limit(10)
  end

  def wiki_pages
    WikiPageVersion
      .joins(:updater)
      .where("wiki_page_versions.created_at > ?", min_date)
      .where("users.level <= ?", max_level)
      .group(:updater)
      .order(Arel.sql("count(*) desc"))
      .limit(10)
      .count
      .to_h
  end
end
