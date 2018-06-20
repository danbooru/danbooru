require 'test_helper'

class UploadTest < ActiveSupport::TestCase
  SOURCE_URL = "https://upload.wikimedia.org/wikipedia/commons/thumb/6/66/NAMA_Machine_d%27Anticyth%C3%A8re_1.jpg/538px-NAMA_Machine_d%27Anticyth%C3%A8re_1.jpg?download"

  context "In all cases" do
    setup do
      mock_iqdb_service!
      user = FactoryBot.create(:contributor_user)
      CurrentUser.user = user
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "An upload" do
      context "from a user that is limited" do
        setup do
          CurrentUser.user = FactoryBot.create(:user, :created_at => 1.year.ago)
          User.any_instance.stubs(:upload_limit).returns(0)
        end

        should "fail creation" do
          @upload = FactoryBot.build(:jpg_upload, :tag_string => "")
          @upload.save
          assert_equal(["You have reached your upload limit for the day"], @upload.errors.full_messages)
        end
      end
    end
  end
end
