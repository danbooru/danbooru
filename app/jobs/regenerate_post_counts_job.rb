# frozen_string_literal: true

# A job that runs hourly to fix all incorrect tag counts.
# Spawned by {DanbooruMaintenance}.
class RegeneratePostCountsJob < ApplicationJob
  def perform
    updated_tags = Tag.regenerate_post_counts!
    updated_tags.each do |tag|
      DanbooruLogger.info("Updated tag count", tag.attributes)
    end
  end
end
