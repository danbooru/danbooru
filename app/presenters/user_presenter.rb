class UserPresenter
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def name
    user.pretty_name
  end

  def join_date
    user.created_at.strftime("%Y-%m-%d")
  end

  def level
    user.level_string
  end

  def ban_reason
    if user.is_banned?
      "#{user.recent_ban.reason}; expires #{user.recent_ban.expires_at} (#{user.bans.count} bans total)"
    else
      nil
    end
  end

  def permissions
    permissions = []

    if user.can_approve_posts?
      permissions << "approve posts"
    end

    if user.can_upload_free?
      permissions << "unrestricted uploads"
    end

    if user.is_super_voter?
      permissions << "super voter"
    end

    permissions.join(", ")
  end

  def posts_for_saved_search_category(category)
    if !SavedSearch.enabled?
      return Post.where("false")
    end

    ids = SavedSearch.post_ids(CurrentUser.user.id, category)

    if ids.any?
      arel = Post.where("id in (?)", ids.map(&:to_i)).order("id desc").limit(10)

      if CurrentUser.user.hide_deleted_posts?
        arel = arel.undeleted
      end

      arel
    else
      Post.where("false")
    end
  end

  def upload_limit
    if user.can_upload_free?
      return "none"
    end

    dcon = [user.deletion_confidence(60), 15].min
    multiplier = (1 - (dcon / 15.0))
    max_count = [(user.base_upload_limit * multiplier).ceil, 5].max
    uploaded_count = Post.for_user(user.id).where("created_at >= ?", 24.hours.ago).count
    uploaded_comic_count = Post.for_user(user.id).tag_match("comic").where("created_at >= ?", 24.hours.ago).count / 3

    "(#{user.base_upload_limit} * #{'%0.2f' % multiplier}) - #{uploaded_count - uploaded_comic_count} = #{user.upload_limit}"
  end

  def uploads
    @uploads ||= begin
      arel = Post.where("uploader_id = ?", user.id).order("id desc").limit(6)

      if CurrentUser.user.hide_deleted_posts?
        arel = arel.undeleted
      end

      arel
    end
  end

  def has_uploads?
    user.post_upload_count > 0
  end

  def favorites
    @favorites ||= begin
      arel = user.favorites.limit(6).joins(:post).reorder("favorites.id desc")

      if CurrentUser.user.hide_deleted_posts?
        arel = arel.where("posts.is_deleted = false")
      end

      arel.map(&:post).compact
    end
  end

  def has_favorites?
    user.favorite_count > 0
  end

  def upload_count(template)
    template.link_to(user.post_upload_count, template.posts_path(:tags => "user:#{user.name}"))
  end

  def deleted_upload_count(template)
    template.link_to(Post.for_user(user.id).deleted.count, template.posts_path(:tags => "status:deleted user:#{user.name}"))
  end

  def favorite_count(template)
    template.link_to(user.favorite_count, template.favorites_path(:user_id => user.id))
  end

  def favorite_group_count(template)
    template.link_to(user.favorite_group_count, template.favorite_groups_path(:search => {:creator_id => user.id}))
  end

  def comment_count(template)
    template.link_to(user.comment_count, template.comments_path(:search => {:creator_id => user.id}, :group_by => "comment"))
  end

  def commented_posts_count(template)
    count = CurrentUser.without_safe_mode { Post.fast_count("commenter:#{user.name}") }
    template.link_to(count, template.posts_path(:tags => "commenter:#{user.name} order:comment_bumped"))
  end

  def post_version_count(template)
    template.link_to(user.post_update_count, template.post_versions_path(:lr => user.id, :search => {:updater_id => user.id}))
  end

  def note_version_count(template)
    template.link_to(user.note_update_count, template.note_versions_path(:search => {:updater_id => user.id}))
  end

  def noted_posts_count(template)
    count = CurrentUser.without_safe_mode { Post.fast_count("noteupdater:#{user.name}") }
    template.link_to(count, template.posts_path(:tags => "noteupdater:#{user.name} order:note"))
  end

  def wiki_page_version_count(template)
    template.link_to(user.wiki_page_version_count, template.wiki_page_versions_path(:search => {:updater_id => user.id}))
  end

  def artist_version_count(template)
    template.link_to(user.artist_version_count, template.artist_versions_path(:search => {:updater_id => user.id}))
  end

  def artist_commentary_version_count(template)
    template.link_to(user.artist_commentary_version_count, template.artist_commentary_versions_path(:search => {:updater_id => user.id}))
  end

  def forum_post_count(template)
    template.link_to(user.forum_post_count, template.forum_posts_path(:search => {:creator_id => user.id}))
  end

  def pool_version_count(template)
    if PoolArchive.enabled?
      template.link_to(user.pool_version_count, template.pool_versions_path(:search => {:updater_id => user.id}))
    else
      "N/A"
    end
  end

  def inviter(template)
    if user.inviter_id
      template.link_to_user(user.inviter)
    else
      "None"
    end
  end

  def appeal_count(template)
    template.link_to(user.appeal_count, template.post_appeals_path(:search => {:creator_name => user.name}))
  end

  def flag_count(template)
    template.link_to(user.flag_count, template.post_flags_path(:search => {:creator_name => user.name}))
  end

  def approval_count(template)
    template.link_to(Post.where("approver_id = ?", user.id).count, template.posts_path(:tags => "approver:#{user.name}"))
  end

  def feedbacks(template)
    positive = user.positive_feedback_count
    neutral = user.neutral_feedback_count
    negative = user.negative_feedback_count

    template.link_to("positive:#{positive} neutral:#{neutral} negative:#{negative}", template.user_feedbacks_path(:search => {:user_id => user.id}))
  end

  def saved_search_labels
    if CurrentUser.user.id == user.id
      SavedSearch.labels_for(CurrentUser.user.id)
    else
      []
    end
  end
  
  def previous_names(template)
    user.user_name_change_requests.map { |req| template.link_to req.original_name, req }.join(", ").html_safe
  end
end
