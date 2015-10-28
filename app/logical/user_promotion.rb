class UserPromotion
  attr_reader :user, :promoter, :new_level, :options, :old_can_approve_posts, :old_can_upload_free

  def initialize(user, promoter, new_level, options = {})
    @user = user
    @promoter = promoter
    @new_level = new_level
    @options = options
  end

  def promote!
    validate

    @old_can_approve_posts = user.can_approve_posts?
    @old_can_upload_free = user.can_upload_free?

    user.level = new_level
    user.can_approve_posts = options[:can_approve_posts]
    user.can_upload_free = options[:can_upload_free]
    user.inviter_id = promoter.id

    create_transaction_log_item
    create_user_feedback unless options[:skip_feedback]
    create_dmail unless options[:skip_dmail]

    user.save
  end

private
  
  def validate
    # admins can do anything
    return if promoter.is_admin?

    # can't promote/demote moderators
    raise User::PrivilegeError if user.is_moderator?

    # can't promote to admin      
    raise User::PrivilegeError if new_level.to_i >= User::Levels::ADMIN
  end

  def create_transaction_log_item
    TransactionLogItem.record_account_upgrade(user)
  end

  def build_messages
    messages = []

    if user.level_changed?
      if user.level > user.level_was
        messages << "You have been promoted to a #{user.level_string} level account from #{user.level_string_was}."
      elsif user.level < user.level_was
        messages << "You have been demoted to a #{user.level_string} level account from #{user.level_string_was}."
      end
    end

    if user.can_approve_posts? && !old_can_approve_posts
      messages << "You gained the ability to approve posts."
    elsif !user.can_approve_posts? && old_can_approve_posts
      messages << "You lost the ability to approve posts."
    end

    if user.can_upload_free? && !old_can_upload_free
      messages << "You gained the ability to upload posts without limit."
    elsif !user.can_upload_free? && old_can_upload_free
      messages << "You lost the ability to upload posts without limit."
    end

    messages.join("\n")
  end

  def create_dmail
    Dmail.create_split(
      :to_id => user.id,
      :title => "You have been promoted",
      :body => build_messages
    )
  end

  def create_user_feedback
    user.feedback.create(
      :category => "neutral",
      :body => build_messages,
      :disable_dmail_notification => true
    )
  end
end
