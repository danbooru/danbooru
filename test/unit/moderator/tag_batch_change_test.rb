require "test_helper"

module Moderator
  class TagBatchChangeTest < ActiveSupport::TestCase
    context "a tag batch change" do
      setup do
        @user = Factory.create(:moderator_user)
        CurrentUser.user = @user
        CurrentUser.ip_addr = "127.0.0.1"
        @post = Factory.create(:post, :tag_string => "aaa")
      end
  
      teardown do
        CurrentUser.user = nil
        CurrentUser.ip_addr = nil
      end

      should "execute" do
        tag_batch_change = TagBatchChange.new("aaa", "bbb")
        tag_batch_change.execute
        @post.reload
        assert_equal("bbb", @post.tag_string)
      end
      
      should "raise an error if there is no predicate" do
        tag_batch_change = TagBatchChange.new("", "bbb")
        assert_raises(TagBatchChange::Error) do
          tag_batch_change.execute
        end
      end
    end
  end
end
