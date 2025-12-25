# frozen_string_literal: true

class UserProfileComponent < ApplicationComponent
  attr_reader :user, :current_user

  delegate :link_to_wiki, :render_post_gallery, :checkmark_icon, :exclamation_icon, to: :helpers

  def initialize(user:, current_user: nil)
    super
    @user = user
    @current_user = current_user
  end

  def posts_for_saved_search_category(category)
    PostQuery.new("search:#{category}", current_user: current_user).posts_with_timeout(10)
  end

  def uploads
    PostQuery.new("user:#{user.name}", current_user: current_user).posts_with_timeout(6, count: user.post_upload_count, includes: [:media_asset, :vote_by_current_user])
  end

  def has_uploads?
    user.post_upload_count > 0
  end

  def favorites
    PostQuery.new("ordfav:#{user.name}", current_user: current_user).posts_with_timeout(6, count: user.favorite_count, includes: [:media_asset, :vote_by_current_user])
  end

  def has_favorites?
    user.favorite_count > 0
  end

  def commented_posts_count
    user.comments.distinct.count(:post_id)
  end

  def noted_posts_count
    user.note_versions.distinct.count(:post_id)
  end

  def positive_feedback_count
    user.positive_feedback_count
  end

  def neutral_feedback_count
    user.neutral_feedback_count
  end

  def negative_feedback_count
    user.negative_feedback_count
  end

  def saved_search_labels
    if current_user == user
      SavedSearch.labels_for(current_user.id)
    else
      []
    end
  end
end
