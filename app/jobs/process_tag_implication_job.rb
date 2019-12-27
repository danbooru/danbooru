class ProcessTagImplicationJob < ApplicationJob
  queue_as :bulk_update

  def perform(tag_implication, update_topic: true)
    tag_implication.process!(update_topic: update_topic)
  end
end
