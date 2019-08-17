class UpdateRelatedTagsJob < ApplicationJob
  queue_as :default

  def perform(tag)
    tag.update_related
  end
end
