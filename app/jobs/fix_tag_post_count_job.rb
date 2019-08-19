class FixTagPostCountJob < ApplicationJob
  queue_as :default
  queue_with_priority 20

  def perform(tag)
    tag.fix_post_count
  end
end
