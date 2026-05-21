module BulkUpdateRequestTestHelper
  def create_bur!(script, approver)
    bur = create(:bulk_update_request, script: script)
    bur.approve!(approver)
    perform_enqueued_jobs(only: ProcessBulkUpdateRequestJob)
    bur
  end
end
