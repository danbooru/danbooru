# frozen_string_literal: true

class ServerStatistics
  extend Memoist
  include ActiveModel::Serializers::JSON
  include ActiveModel::Serializers::Xml

  def initialize
    @number_helper = Object.new.extend(ActionView::Helpers::NumberHelper)
  end

  def self.cached
    Cache.get("server-statistics", 24.hours) do
      new.serializable_hash
    end
  end

  def self.purge_cache
    Cache.delete("server-statistics")
    cached
  end

  def size(num)
    return "0 B" unless num.present?
    @number_helper.number_to_human_size(num)
  end

  def delim(num)
    return "0" unless num.present?
    @number_helper.number_with_delimiter(num)
  end

  def serializable_hash(options = {})
    {
      site: site_info,
      posts: post_info,
      files: file_info,
      users: user_info,
      comments: comment_info,
      forum: forum_info,
      tags: tag_info,
      bulk_update_requets: bur_info,
    }
  end

  def site_info
    {
      started: Post.minimum(:created_at),
      database_size: size(database_size),
    }
  end

  def post_info
    hash = {
      total_posts: delim(Post.maximum(:id)),
      average_file_size: size(Post.average(:file_size)),
      total_file_size: size(Post.sum(:file_size)),
      total_favorites: delim(Favorite.count),
      total_post_votes: delim(PostVote.count),
    }

    Post::RATINGS.each do |rating, name|
      hash[:"#{name}_posts"] = delim(Post.where(rating: rating).count)
    end

    hash
  end

  def file_info
    {
      total_files: delim(MediaAsset.maximum(:id)),
      average_file_size: size(MediaAsset.average(:file_size)),
      total_file_size: size(MediaAsset.sum(:file_size)),
      unposted_files: delim(MediaAsset.where.missing(:post).count),
    }
  end

  def user_info
    hash = {
      user_count: delim(User.maximum(:id)),
      dmails_sent: delim(Dmail.maximum(:id)&./(2)),
    }

    User::Levels.constants.without(:ANONYMOUS).each do |level|
      hash[level.to_s.pluralize] = delim(User.where(level: User::Levels.const_get(level)).count)
    end

    hash[:banned_users] = delim(User.bit_prefs_match("is_banned", true).count)

    hash
  end

  def comment_info
    {
      comment_count: delim(Comment.maximum(:id) || 0),
      active_comments: delim(Comment.where(is_deleted: false).count),
      deleted_comments: delim(Comment.where(is_deleted: true).count),
      total_comment_votes: delim(CommentVote.count),
    }
  end

  def forum_info
    {
      forum_posts: delim(ForumPost.count),
      forum_topics: delim(ForumTopic.maximum(:id)),
      average_posts_per_topic: ForumPost.count / ForumTopic.count
    }
  end

  def tag_info
    hash = {
      tag_count: delim(Tag.maximum(:id)),
      empty_tags: delim(Tag.empty.count),
      nonempty_tags: delim(Tag.nonempty.count),
      deprecated_tags: delim(Tag.deprecated.count),
      undeprecated_tags: delim(Tag.undeprecated.count),
    }

    TagCategory.reverse_mapping.each do |k, v|
      hash[:"#{v}_tag_count"] = delim(Tag.where(category: k).count)
    end

    hash
  end

  def bur_info
    {
      total_bulk_update_requests: delim(BulkUpdateRequest.count),
      pending_bulk_update_requests: delim(BulkUpdateRequest.pending.count),
      rejected_bulk_update_requests: delim(BulkUpdateRequest.rejected.count),
      approved_bulk_update_requests: delim(BulkUpdateRequest.approved.count),
      failed_bulk_update_requests: delim(BulkUpdateRequest.failed.count),
    }
  end

  def database_size
    database = ActiveRecord::Base.connection.current_database
    query = ActiveRecord::Base.sanitize_sql(["SELECT pg_database_size(?)", database])
    result = ActiveRecord::Base.connection.exec_query(query)
    result.first&.fetch("pg_database_size", 0)
  end
end
