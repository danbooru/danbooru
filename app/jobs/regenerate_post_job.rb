class RegeneratePostJob < ApplicationJob
  queue_as :default
  queue_with_priority 20

  def perform(post:, category:, user:)
    post.regenerate!(category, user)
  end
end
