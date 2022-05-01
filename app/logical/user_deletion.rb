# frozen_string_literal: true

# Delete a user's account. Deleting an account really just deactivates the
# account, it doesn't fully delete the user from the database. It wipes their
# username, password, account settings, favorites, and saved searches, and logs
# the deletion.
class UserDeletion
  include ActiveModel::Validations

  attr_reader :user, :password, :request

  validate :validate_deletion

  # Initialize a user deletion.
  # @param user [User] the user to delete
  # @param password [String] the user's password (for confirmation)
  # @param request the HTTP request (for logging the deletion in the user event log)
  def initialize(user, password, request)
    @user = user
    @password = password
    @request = request
  end

  # Delete the account, if the deletion is allowed.
  # @return [Boolean] if the deletion failed
  # @return [User] if the deletion succeeded
  def delete!
    return false if invalid?

    clear_user_settings
    remove_favorites
    clear_saved_searches
    rename
    reset_password
    create_mod_action
    create_user_event
    user
  end

  private

  def create_mod_action
    ModAction.log("user ##{user.id} deleted", :user_delete)
  end

  def create_user_event
    UserEvent.create_from_request!(user, :user_deletion, request)
  end

  def clear_saved_searches
    SavedSearch.where(user_id: user.id).destroy_all
  end

  def clear_user_settings
    user.email_address = nil
    user.last_logged_in_at = nil
    user.last_forum_read_at = nil
    user.favorite_tags = ""
    user.blacklisted_tags = ""
    user.show_deleted_children = false
    user.time_zone = "Eastern Time (US & Canada)"
    user.save!
  end

  def reset_password
    user.update!(password: SecureRandom.hex(16))
  end

  def remove_favorites
    DeleteFavoritesJob.perform_later(user)
  end

  def rename
    name = "user_#{user.id}"
    name += "~" while User.exists?(name: name)

    request = UserNameChangeRequest.new(user: user, desired_name: name, original_name: user.name)
    request.save!(validate: false) # XXX don't validate so that the 1 name change per week rule doesn't interfere
  end

  def validate_deletion
    if !user.authenticate_password(password)
      errors.add(:base, "Password is incorrect")
    end

    if user.is_admin?
      errors.add(:base, "Admins cannot delete their account")
    end

    if user.is_banned?
      errors.add(:base, "You cannot delete your account if you are banned")
    end
  end
end
