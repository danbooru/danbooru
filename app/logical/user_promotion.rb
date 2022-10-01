# frozen_string_literal: true

# Promotes the user to a higher level, or grants them approver or unlimited
# uploader privileges. Also validates that the promotion is allowed, gives the
# user a feedback, sends them a notification dmail, and creates a mod action for
# the promotion.
class UserPromotion
  attr_reader :user, :promoter, :new_level

  # Initialize a new promotion.
  # @param user [User] the user to promote
  # @param promoter [User] the user doing the promotion
  # @param new_level [Integer] the new user level
  def initialize(user, promoter, new_level)
    @user = user
    @promoter = promoter
    @new_level = new_level.to_i
  end

  def promote!
    user.level = new_level

    create_user_feedback
    create_dmail
    create_mod_actions

    user.save
  end

  private

  def create_mod_actions
    if user.level_changed? && user.level >= user.level_was
      ModAction.log(%{promoted "#{user.name}":#{Routes.user_path(user)} from #{user.level_string_was} to #{user.level_string}}, :user_level_change, subject: user, user: promoter)
    elsif user.level_changed? && user.level < user.level_was
      ModAction.log(%{demoted "#{user.name}":#{Routes.user_path(user)} from #{user.level_string_was} to #{user.level_string}}, :user_level_change, subject: user, user: promoter)
    end
  end

  # Build the dmail and user feedback message.
  def build_message
    level_string = (user.level == User::Levels::APPROVER) ? "an Approver" : "a #{user.level_string}"
    if user.level > user.level_was
      "You have been promoted to #{level_string} level account from #{user.level_string_was}."
    elsif user.level < user.level_was
      "You have been demoted to #{level_string} level account from #{user.level_string_was}."
    end
  end

  def create_dmail
    Dmail.create_automated(to_id: user.id, title: "Your account has been updated", body: build_message)
  end

  def create_user_feedback
    UserFeedback.create(user: user, creator: promoter, category: "neutral", body: build_message, disable_dmail_notification: true)
  end
end
