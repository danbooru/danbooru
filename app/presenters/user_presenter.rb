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
      "#{user.ban.reason}; expires #{user.ban.expires_at}"
    else
      nil
    end
  end

  def posts_for_subscription(subscription)
    Post.where("id in (?)", subscription.post_id_array.slice(0, 6).map(&:to_i)).order("id desc")
  end

  def tag_links_for_subscription(template, subscription)
    subscription.tag_query_array.map {|x| template.link_to(x.tr("_", " "), template.posts_path(:tags => x))}.join(", ").html_safe
  end

  def upload_limit
    if user.is_contributor?
      return "none"
    end
    
    deleted_count = Post.for_user(user.id).deleted.where("is_banned = false").count
    pending_count = Post.for_user(user.id).pending.count
    approved_count = Post.where("is_flagged = false and is_pending = false and is_deleted = false and uploader_id = ?", user.id).count

    if user.base_upload_limit.to_i != 0
      string = "max(base:#{user.base_upload_limit} - (deleted:#{deleted_count} / 4), 4) - pending:#{pending_count}"
    else
      string = "max(10 + (approved:#{approved_count} / 10) - (deleted:#{deleted_count} / 4), 4) - pending:#{pending_count}"
    end
    
    "#{string} = #{user.upload_limit}"
  end

  def uploads
    @uploads ||= Post.where("uploader_id = ?", user.id).order("id desc").limit(6)
  end

  def has_uploads?
    user.post_upload_count > 0
  end

  def favorites
    @favorites ||= user.favorites.limit(6).includes(:post).reorder("favorites.id desc").map(&:post)
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
    template.link_to(user.favorite_count, template.posts_path(:tags => "fav:#{user.name}"))
  end

  def comment_count(template)
    template.link_to(Comment.for_creator(user.id).count, template.comments_path(:search => {:creator_id => user.id}, :group_by => "comment"))
  end

  def post_version_count(template)
    template.link_to(user.post_update_count, template.post_versions_path(:search => {:updater_id => user.id}))
  end

  def note_version_count(template)
    template.link_to(user.note_update_count, template.note_versions_path(:search => {:updater_id => user.id}))
  end

  def wiki_page_version_count(template)
    template.link_to(WikiPageVersion.for_user(user.id).count, template.wiki_page_versions_path(:search => {:updater_id => user.id}))
  end

  def forum_post_count(template)
    template.link_to(ForumPost.for_user(user.id).count, template.forum_posts_path(:search => {:creator_id => user.id}))
  end

  def pool_version_count(template)
    template.link_to(PoolVersion.for_user(user.id).count, template.pool_versions_path(:search => {:updater_id => user.id}))
  end

  def inviter(template)
    if user.inviter_id
      template.link_to_user(user.inviter)
    else
      "None"
    end
  end

  def approval_count(template)
    template.link_to(Post.where("approver_id = ?", user.id).count, template.posts_path(:tags => "approver:#{user.name}"))
  end

  def feedbacks(template)
    positive = UserFeedback.for_user(user.id).positive.count
    neutral = UserFeedback.for_user(user.id).neutral.count
    negative = UserFeedback.for_user(user.id).negative.count

    template.link_to("positive:#{positive} neutral:#{neutral} negative:#{negative}", template.user_feedbacks_path(:search => {:user_id => user.id}))
  end

  def subscriptions
    if CurrentUser.user.id == user.id
      user.subscriptions
    else
      user.subscriptions.select {|x| x.is_public?}
    end
  end
  
  def previous_names
    UserNameChangeRequest.approved.where("user_id = ?", user.id).map(&:original_name).join(", ")
  end
end
