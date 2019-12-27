class ProcessTagAliasJob < ApplicationJob
  queue_as :bulk_update

  def perform(tag_alias, update_topic: true)
    tag_alias.process!(update_topic: update_topic)
  end
end
