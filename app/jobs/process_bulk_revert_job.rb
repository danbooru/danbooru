class ProcessBulkRevertJob < ApplicationJob
  queue_as :default
  queue_with_priority 20

  def perform(creator, constraints)
    BulkRevert.new.process(creator, constraints)
  end
end
