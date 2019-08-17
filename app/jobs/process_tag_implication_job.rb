class ProcessTagImplicationJob < ApplicationJob
  queue_as :default
  queue_with_priority 20

  def perform(tag_implication, update_topic: true)
    tag_implication.process!(update_topic: update_topic)
  end
end
