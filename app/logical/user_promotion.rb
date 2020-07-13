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

    if options.key?(:can_approve_posts)
      user.can_approve_posts = options[:can_approve_posts]
    end

    if options.key?(:can_upload_free)
      user.can_upload_free = options[:can_upload_free]
    end

    user.inviter_id = promoter.id

    create_user_feedback unless options[:is_upgrade]
    create_dmail unless options[:skip_dmail]
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
      category = options[:is_upgrade] ? :user_account_upgrade : :user_level_change
      ModAction.log(%{"#{user.name}":/users/#{user.id} level changed #{user.level_string_was} -> #{user.level_string}}, category)
    end
  end

  def validate
    # admins can do anything
    return if promoter.is_admin?

    # can't promote/demote moderators
    raise User::PrivilegeError if user.is_moderator?

    # can't promote to admin
    raise User::PrivilegeError if new_level.to_i >= User::Levels::ADMIN
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
