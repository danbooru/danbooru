# frozen_string_literal: true

# A job that updates the `tag_count_{category}` field on posts when a tag's category is changed.
class UpdateTagCategoryPostCountsJob < ApplicationJob
  def perform(tag)
    tag.update_tag_category_post_counts
  end
end
