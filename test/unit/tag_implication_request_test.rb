require 'test_helper'

class TagImplicationRequestTest < ActiveSupport::TestCase
  context "A tag implication request" do
    setup do
      @user = FactoryGirl.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      MEMCACHE.flush_all
      Delayed::Worker.delay_jobs = false
    end

    teardown do
      MEMCACHE.flush_all
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    should "raise an exception if invalid" do
      assert_raises(TagImplicationRequest::ValidationError) do
        TagImplicationRequest.new("", "", "reason").create
      end
    end
    
    should "create a tag implication" do
      assert_difference("TagImplication.count", 1) do
        TagImplicationRequest.new("aaa", "bbb", "reason").create
      end
      assert_equal("pending", TagImplication.last.status)
    end

    should "create a forum topic" do
      assert_difference("ForumTopic.count", 1) do
        TagImplicationRequest.new("aaa", "bbb", "reason").create
      end
    end

    should "create a forum post" do
      assert_difference("ForumPost.count", 1) do
        TagImplicationRequest.new("aaa", "bbb", "reason").create
      end
    end
  end
end
