class ProcessTagImplicationJob < ApplicationJob
  queue_as :bulk_update

  def perform(tag_implication)
    tag_implication.process!
  end
end
