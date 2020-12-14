class UserPromotion
  attr_reader :user, :promoter, :new_level, :old_can_approve_posts, :old_can_upload_free, :can_upload_free, :can_approve_posts, :is_upgrade

  def initialize(user, promoter, new_level, can_upload_free: nil, can_approve_posts: nil, is_upgrade: false)
    @user = user
    @promoter = promoter
    @new_level = new_level.to_i
    @can_upload_free = can_upload_free
    @can_approve_posts = can_approve_posts
    @is_upgrade = is_upgrade
  end

  def promote!
    validate!

    @old_can_approve_posts = user.can_approve_posts?
    @old_can_upload_free = user.can_upload_free?

    user.level = new_level
    user.can_upload_free = can_upload_free unless can_upload_free.nil?
    user.can_approve_posts = can_approve_posts unless can_approve_posts.nil?
    user.inviter = promoter

    create_user_feedback unless is_upgrade
    create_dmail
    create_mod_actions

    user.save
  end

  private

  def create_mod_actions
    if old_can_approve_posts != user.can_approve_posts?
      ModAction.log("\"#{promoter.name}\":/users/#{promoter.id} changed approval privileges for \"#{user.name}\":/users/#{user.id} from #{old_can_approve_posts} to [b]#{user.can_approve_posts?}[/b]", :user_approval_privilege)
    end

    if old_can_upload_free != user.can_upload_free?
      ModAction.log("\"#{promoter.name}\":/users/#{promoter.id} changed unlimited upload privileges for \"#{user.name}\":/users/#{user.id} from #{old_can_upload_free} to [b]#{user.can_upload_free?}[/b]", :user_upload_privilege)
    end

    if user.level_changed?
      category = is_upgrade ? :user_account_upgrade : :user_level_change
      ModAction.log(%{"#{user.name}":/users/#{user.id} level changed #{user.level_string_was} -> #{user.level_string}}, category)
    end
  end

  def validate!
    if !promoter.is_moderator?
      raise User::PrivilegeError, "You can't promote or demote other users"
    elsif promoter == user
      raise User::PrivilegeError, "You can't promote or demote yourself"
    elsif new_level >= promoter.level
      raise User::PrivilegeError, "You can't promote other users to your rank or above"
    elsif user.level >= promoter.level
      raise User::PrivilegeError, "You can't promote or demote other users at your rank or above"
    elsif is_upgrade && user.is_builder?
      raise User::PrivilegeError, "You can't upgrade a user that is above Platinum level"
    end
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
    Dmail.create_automated(to_id: user.id, title: "Your account has been updated", body: build_messages)
  end

  def create_user_feedback
    UserFeedback.create(user: user, creator: promoter, category: "neutral", body: build_messages, disable_dmail_notification: true)
  end
end
