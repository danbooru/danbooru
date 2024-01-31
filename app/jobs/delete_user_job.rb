# frozen_string_literal: true

# A job that deletes a user's settings and other personal data when they delete their account.
class DeleteUserJob < ApplicationJob
  def perform(user)
    UserDeletion.new(user: user).delete_user
  end
end
