class ProcessTagImplicationJob < ApplicationJob
  queue_as :bulk_update

  def perform(tag_implication, approver)
    tag_implication.process!(approver)
  end
end
