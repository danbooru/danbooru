# frozen_string_literal: true

# Promotes the user to a higher level, or grants them approver or unlimited
# uploader privileges. Also validates that the promotion is allowed, gives the
# user a feedback, sends them a notification dmail, and creates a mod action for
# the promotion.
class UserPromotion
  attr_reader :user, :promoter, :new_level, :old_can_approve_posts, :old_can_upload_free, :can_upload_free, :can_approve_posts

  # Initialize a new promotion.
  # @param user [User] the user to promote
  # @param promoter [User] the user doing the promotion
  # @param new_level [Integer] the new user level
  # @param can_upload_free [Boolean] whether the user should gain unlimited upload privileges
  # @param can_approve_posts [Boolean] whether the user should gain approval privileges
  def initialize(user, promoter, new_level, can_upload_free: nil, can_approve_posts: nil)
    @user = user
    @promoter = promoter
    @new_level = new_level.to_i
    @can_upload_free = can_upload_free
    @can_approve_posts = can_approve_posts
  end

  def promote!
    validate!

    @old_can_approve_posts = user.can_approve_posts?
    @old_can_upload_free = user.can_upload_free?

    user.level = new_level
    user.can_upload_free = can_upload_free unless can_upload_free.nil?
    user.can_approve_posts = can_approve_posts unless can_approve_posts.nil?

    create_user_feedback
    create_dmail
    create_mod_actions

    user.save
  end

  private

  def create_mod_actions
    if old_can_approve_posts == false && user.can_approve_posts? == true
      ModAction.log("granted approval privileges to \"#{user.name}\":#{Routes.user_path(user)}", :user_approval_privilege, subject: user, user: promoter)
    elsif old_can_approve_posts == true && user.can_approve_posts? == false
      ModAction.log("removed approval privileges from \"#{user.name}\":#{Routes.user_path(user)}", :user_approval_privilege, subject: user, user: promoter)
    end

    if old_can_upload_free == false && user.can_upload_free? == true
      ModAction.log("granted unlimited upload privileges to \"#{user.name}\":#{Routes.user_path(user)}", :user_upload_privilege, subject: user, user: promoter)
    elsif old_can_upload_free == false && user.can_upload_free? == true
      ModAction.log("removed unlimited upload privileges from \"#{user.name}\":#{Routes.user_path(user)}", :user_upload_privilege, subject: user, user: promoter)
    end

    if user.level_changed? && user.level >= user.level_was
      ModAction.log(%{promoted "#{user.name}":#{Routes.user_path(user)} from #{user.level_string_was} to #{user.level_string}}, :user_level_change, subject: user, user: promoter)
    elsif user.level_changed? && user.level < user.level_was
      ModAction.log(%{demoted "#{user.name}":#{Routes.user_path(user)} from #{user.level_string_was} to #{user.level_string}}, :user_level_change, subject: user, user: promoter)
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
    end
  end

  # Build the dmail and user feedback message.
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
