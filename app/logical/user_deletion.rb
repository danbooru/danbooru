# frozen_string_literal: true

# Delete a user's account. Deleting an account really just deactivates the
# account, it doesn't fully delete the user from the database. It wipes their
# username, password, account settings, favorites, and saved searches, and logs
# the deletion.
class UserDeletion
  include ActiveModel::Validations

  attr_reader :user, :deleter, :password, :request

  validate :validate_deletion

  # Initialize a user deletion.
  #
  # @param user [User] the user to delete
  # @param deleter [User] the user performing the deletion
  # @param password [String] the user's password (for confirmation)
  # @param request the HTTP request (for logging the deletion in the user event log)
  def initialize(user:, deleter: user, password: nil, request: nil)
    @user = user
    @deleter = deleter
    @password = password
    @request = request
  end

  # Delete the account, if the deletion is allowed.
  #
  # @return [Boolean] True if the deletion was successful, false otherwise.
  def delete!
    return false if invalid?

    user.with_lock do
      rename
      reset_password
      async_delete_user
      ModAction.log("deleted user ##{user.id}", :user_delete, subject: user, user: deleter)
      UserEvent.create_from_request!(user, :user_deletion, request) if request.present?
      SessionLoader.new(request).logout(user) if user == deleter
    end

    true
  end

  # Calls `delete_user`.
  def async_delete_user
    DeleteUserJob.perform_later(user)
  end

  def delete_user
    delete_user_data
    delete_user_settings
  end

  def delete_user_data
    user.api_keys.destroy_all
    user.forum_topic_visits.destroy_all
    user.saved_searches.destroy_all
    user.favorite_groups.is_private.destroy_all

    user.post_votes.active.negative.find_each do |vote|
      vote.soft_delete!(updater: user)
    end

    if user.enable_private_favorites
      user.favorites.destroy_all
      user.post_votes.active.positive.find_each do |vote|
        vote.soft_delete!(updater: user)
      end
    end
  end

  def delete_user_settings
    user.email_address = nil
    user.last_logged_in_at = nil
    user.last_forum_read_at = nil

    User::USER_PREFERENCE_BOOLEAN_ATTRIBUTES.each do |attribute|
      user.send("#{attribute}=", false)
    end

    %w[time_zone comment_threshold default_image_size favorite_tags blacklisted_tags custom_style per_page theme].each do |attribute|
      user[attribute] = User.column_defaults[attribute]
    end

    user.save!
  end

  def reset_password
    user.update!(password: SecureRandom.hex(16))
  end

  def rename
    name = "user_#{user.id}"
    name += "~" while User.exists?(name: name)

    request = UserNameChangeRequest.new(user: user, desired_name: name, original_name: user.name)
    request.save!(validate: false) # XXX don't validate so that the 1 name change per week rule doesn't interfere
  end

  def validate_deletion
    if user == deleter
      if !user.authenticate_password(password)
        errors.add(:base, "Password is incorrect")
      end

      if user.is_admin?
        errors.add(:base, "Admins cannot delete their account")
      end

      if user.is_banned?
        errors.add(:base, "You cannot delete your account if you are banned")
      end
    else
      if !deleter.is_owner?
        errors.add(:base, "You cannot delete an account belonging to another user")
      end

      if user.is_gold?
        errors.add(:base, "You cannot delete a privileged account")
      end
    end
  end
end
