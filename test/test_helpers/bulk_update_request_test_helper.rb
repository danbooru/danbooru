module BulkUpdateRequestTestHelper
  extend ActiveSupport::Concern

  def create_bur!(script, approver)
    bur = create(:bulk_update_request, script: script)
    bur.approve!(approver)
    perform_enqueued_jobs(only: ProcessBulkUpdateRequestJob)
    bur
  end

  def assert_invalid_bur(script:, errors:)
    bur = build(:bulk_update_request, script: script)
    assert_equal(false, bur.valid?)
    assert_equal(errors.sort, bur.errors.full_messages.sort)
    bur
  rescue Minitest::Assertion => e
    e.set_backtrace(e.backtrace.reject { |frame| frame.include?(__FILE__) })
    raise e
  end
end
