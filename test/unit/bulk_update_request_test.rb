require 'test_helper'

class BulkUpdateRequestTest < ActiveSupport::TestCase
  context "creation" do
    setup do
      CurrentUser.user = FactoryGirl.create(:user)
    end

    teardown do
      CurrentUser.user = nil
    end

    should "create a forum topic" do
      assert_difference("ForumTopic.count", 1) do
        BulkUpdateRequest.create(:title => "abc", :reason => "zzz", :script => "create alias aaa -> bbb")
      end
    end
  end
end
