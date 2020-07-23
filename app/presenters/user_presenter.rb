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

    permissions.join(", ")
  end

  def posts_for_saved_search_category(category)
    Post.user_tag_match("search:#{category}").limit(10)
  end

  def uploads
    Post.user_tag_match("user:#{user.name}").limit(6)
  end

  def has_uploads?
    user.post_upload_count > 0
  end

  def favorites
    Post.user_tag_match("ordfav:#{user.name}").limit(6)
  end

  def has_favorites?
    user.favorite_count > 0
  end

  def upload_count(template)
    template.link_to(user.post_upload_count, template.posts_path(tags: "user:#{user.name}"), rel: "nofollow")
  end

  def deleted_upload_count(template)
    template.link_to(user.posts.deleted.count, template.posts_path(tags: "status:deleted user:#{user.name}"), rel: "nofollow")
  end

  def favorite_count(template)
    template.link_to(user.favorite_count, template.posts_path(tags: "ordfav:#{user.name}"), rel: "nofollow")
  end

  def favorite_group_count(template)
    template.link_to(user.favorite_group_count, template.favorite_groups_path(search: { creator_name: user.name }))
  end

  def comment_count(template)
    template.link_to(user.comment_count, template.comments_path(:search => {:creator_id => user.id}, :group_by => "comment"))
  end

  def commented_posts_count(template)
    count = PostQueryBuilder.new("commenter:#{user.name}").fast_count
    count = "?" if count.nil?
    template.link_to(count, template.posts_path(tags: "commenter:#{user.name} order:comment_bumped"), rel: "nofollow")
  end

  def post_version_count(template)
    template.link_to(user.post_update_count, template.post_versions_path(:search => {:updater_id => user.id}))
  end

  def note_version_count(template)
    template.link_to(user.note_update_count, template.note_versions_path(:search => {:updater_id => user.id}))
  end

  def noted_posts_count(template)
    count = PostQueryBuilder.new("noteupdater:#{user.name}").fast_count
    count = "?" if count.nil?
    template.link_to(count, template.posts_path(tags: "noteupdater:#{user.name} order:note"), rel: "nofollow")
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
    template.link_to(user.forum_post_count, template.forum_posts_path(search: { creator_id: user.id }), rel: "nofollow")
  end

  def pool_version_count(template)
    if PoolVersion.enabled?
      template.link_to(user.pool_version_count, template.pool_versions_path(:search => {:updater_id => user.id}))
    else
      "N/A"
    end
  end

  def appeal_count(template)
    template.link_to(user.appeal_count, template.post_appeals_path(:search => {:creator_name => user.name}))
  end

  def flag_count(template)
    template.link_to(user.flag_count, template.post_flags_path(:search => {:creator_name => user.name}))
  end

  def approval_count(template)
    template.link_to(Post.where(approver: user).count, template.posts_path(tags: "approver:#{user.name}"), rel: "nofollow")
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
end
