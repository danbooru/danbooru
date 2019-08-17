class DeleteFavoritesJob < ApplicationJob
  queue_as :default
  queue_with_priority 20

  def perform(user)
    Post.without_timeout do
      user.favorites.find_each do |favorite|
        Favorite.remove(post: favorite.post, user: user)
      end
    end
  end
end
