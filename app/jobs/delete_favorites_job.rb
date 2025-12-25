# frozen_string_literal: true

# A job that deletes a user's favorites when they delete their account.
class DeleteFavoritesJob < ApplicationJob
  def perform(user)
    Post.without_timeout do
      user.favorites.destroy_all
    end
  end
end
