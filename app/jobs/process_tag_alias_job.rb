class ProcessTagAliasJob < ApplicationJob
  queue_as :default
  queue_with_priority 20

  def perform(tag_alias, update_topic: true)
    tag_alias.process!(update_topic: update_topic)
  end
end
