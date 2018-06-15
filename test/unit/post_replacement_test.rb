require 'test_helper'

class PostReplacementTest < ActiveSupport::TestCase
  def setup
    super

    mock_iqdb_service!
    Delayed::Worker.delay_jobs = true # don't delete the old images right away

    @system = FactoryBot.create(:user, created_at: 2.weeks.ago)
    User.stubs(:system).returns(@system)

    @uploader = FactoryBot.create(:user, created_at: 2.weeks.ago, can_upload_free: true)
    @replacer = FactoryBot.create(:user, created_at: 2.weeks.ago, can_approve_posts: true)
    CurrentUser.user = @replacer
    CurrentUser.ip_addr = "127.0.0.1"
  end

  def teardown
    super

    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
    Delayed::Worker.delay_jobs = false
  end

  context "Replacing" do
    setup do
      CurrentUser.scoped(@uploader, "127.0.0.2") do
        attributes = FactoryBot.attributes_for(:jpg_upload, as_pending: "0", tag_string: "lowres tag1")
        service = UploadService.new(attributes)
        upload = service.start!
        @post = upload.post
      end
    end
  end
end
