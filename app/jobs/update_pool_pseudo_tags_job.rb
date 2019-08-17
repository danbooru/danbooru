class UpdatePoolPseudoTagsJob < ApplicationJob
  queue_as :default
  queue_with_priority 20

  def perform(pool)
    pool.update_category_pseudo_tags_for_posts
  end
end
