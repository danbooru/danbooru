module BulkUpdateRequestTestHelper
  extend ActiveSupport::Concern

  def create_bur!(script, approver)
    bur = create(:bulk_update_request, script: script)
    bur.approve!(approver)
    assert_empty(bur.errors.full_messages)
    perform_enqueued_jobs(only: ProcessBulkUpdateRequestJob)
    assert_equal("approved", bur.reload.status)
    bur
  end

  # @param bur [BulkUpdateRequest, String] the BUR, or a script to create a new BUR from
  def assert_can_approve_bur(bur, approver)
    bur = create(:bulk_update_request, script: bur) if bur.is_a?(String)
    bur.approve!(approver)
    assert_empty(bur.errors.full_messages, bur.script)
    assert_equal(true, bur.reload.is_approved?, bur.script)
    bur
  rescue Minitest::Assertion => e
    e.set_backtrace(e.backtrace.reject { |frame| frame.include?(__FILE__) })
    raise e
  end

  # Assert that approving the BUR fails and leaves it pending.
  #
  # @param bur [BulkUpdateRequest, String] the BUR, or a script to create a new BUR from
  # @param error [String, nil] the exact error message, if it should be checked
  def assert_cannot_approve_bur(bur, approver, error = nil)
    bur = create(:bulk_update_request, script: bur) if bur.is_a?(String)
    bur.approve!(approver)
    assert_not_empty(bur.errors.full_messages, bur.script)
    assert_includes(bur.errors.full_messages, error) if error.present?
    assert_equal("pending", bur.reload.status, bur.script)
    bur
  rescue Minitest::Assertion => e
    e.set_backtrace(e.backtrace.reject { |frame| frame.include?(__FILE__) })
    raise e
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
