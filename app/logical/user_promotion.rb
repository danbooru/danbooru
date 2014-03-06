class UserPromotion
  attr_reader :user, :promoter, :new_level

  def initialize(user, promoter, new_level)
    @user = user
    @promoter = promoter
    @new_level = new_level
  end

  def promote!
    user.level = new_level
    user.inviter_id = promoter.id

    validate
    create_transaction_log_item
    create_user_feedback

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
      :body => "#{body_prefix} by #{promoter.name} from #{user.level_string_was} to #{user.level_string}"
    )
  end
end
