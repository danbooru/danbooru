class UserPromotion
  attr_reader :user, :promoter, :new_level, :options

  def initialize(user, promoter, new_level, options = {})
    @user = user
    @promoter = promoter
    @new_level = new_level
    @options = options
  end

  def promote!
    validate

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

  def create_user_feedback
    if user.level > user.level_was
      body_prefix = "Promoted"
    elsif user.level < user.level_was
      body_prefix = "Demoted"
    else
      body_prefix = "Updated"
    end

    user.feedback.create(
      :category => "neutral",
      :body => "#{body_prefix} from #{user.level_string_was} to #{user.level_string}",
      :disable_dmail_notification => true
    )
  end

  def create_dmail
    if user.level >= user.level_was || user.bit_prefs_changed?
      create_promotion_dmail
    else
      create_demotion_dmail
    end
  end

  def create_promotion_dmail
    approval_text = if user.can_approve_posts?
      "You can approve posts."
    else
      ""
    end

    upload_text = if user.can_upload_free?
      "You can upload posts without limit."
    else
      ""
    end

    Dmail.create_split(
      :to_id => user.id,
      :title => "You have been promoted",
      :body => "You have been promoted to a #{user.level_string} level account. #{approval_text} #{upload_text}"
    )
  end

  def create_demotion_dmail
    Dmail.create_split(
      :to_id => user.id,
      :title => "You have been demoted",
      :body => "You have been demoted to a #{user.level_string} level account. #{approval_text} #{upload_text}"
    )
  end
end
