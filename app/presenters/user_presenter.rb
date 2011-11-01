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
  
  def tag_subscriptions(template)
    user.subscriptions.map do |subscription|
      template.link_to(subscription.name, template.tag_subscription_path(subscription))
    end.join("; ")
  end
  
  def upload_limit
    deleted_count = Post.for_user(user.id).deleted.count
    pending_count = Post.for_user(user.id).pending.count
    approved_count = Post.where("is_flagged = false and is_pending = false and uploader_id = ?", user.id).count
    
    if user.base_upload_limit
      limit = user.base_upload_limit - pending_count
      string = "base:#{user.base_upload_limit} - pending:#{pending_count}"
    else
      limit = 10 + (approved_count / 10) - (deleted_count / 4) - pending_count
      string = "base:10 + approved:(#{approved_count} / 10) - deleted:(#{deleted_count}) / 4 - pending:#{pending_count}"
    end
    
    if limit > 20
      limit = 20
      string += " = capped:20"
    elsif limit < 0
      limit = 0
      string += " = capped:0"
    else
      string += " = #{limit}"
    end

    return string
  end
  
  def uploads(template)
    template.link_to(user.post_upload_count, template.posts_path(:tags => "uploader:#{user.name}"))
  end
  
  def deleted_uploads(template)
    template.link_to(Post.for_user(user.id).deleted.count, template.posts_path(:tags => "status:deleted uploader:#{user.name}"))
  end
  
  def favorites(template)
    template.link_to(user.favorite_count, template.favorites_path(:user_id => user.id))
  end
  
  def comments(template)
    template.link_to(Comment.for_user(user.id).count, template.comments_path(:search => {:creator_id_eq => user.id}))
  end
  
  def post_versions(template)
    template.link_to(user.post_update_count, template.post_versions_path(:search => {:updater_id_eq => user.id}))
  end
  
  def note_versions(template)
    template.link_to(user.note_update_count, template.note_versions_path(:search => {:updater_id_eq => user.id}))
  end
  
  def wiki_page_versions(template)
    template.link_to(WikiPageVersion.for_user(user.id).count, template.wiki_page_versions_path(:search => {:updater_id_eq => user.id}))
  end
  
  def forum_posts(template)
    template.link_to(ForumPost.for_user(user.id).count, template.forum_posts_path(:search => {:creator_id_eq => user.id}))
  end
  
  def pool_versions(template)
    template.link_to(PoolVersion.for_user(user.id).count, template.pool_versions_path(:search => {:updater_id_eq => user.id}))
  end
  
  def inviter(template)
    if user.inviter_id
      template.link_to(user.inviter.name, template.user_path(user.inviter_id))
    else
      "None"
    end
  end
  
  def approvals(template)
    template.link_to(Post.where("approver_id = ?", user.id).count, template.posts_path(:tags => "approver:#{user.name}"))
  end
  
  def feedbacks(template)
    positive = UserFeedback.for_user(user.id).positive.count
    neutral = UserFeedback.for_user(user.id).neutral.count
    negative = UserFeedback.for_user(user.id).negative.count
    
    template.link_to("positive:#{positive} neutral:#{neutral} negative:#{negative}", template.user_feedbacks_path(:search => {:user_id_eq => user.id}))
  end
  
  def subscriptions(template)
    if user.subscriptions.any?
      user.subscriptions.map do |subscription|
        template.link_to(subscription.name, template.posts_path(:tags => "sub:#{user.name}:#{subscription.name}"))
      end.join(", ").html_safe
    else
      "None"
    end
  end
end
