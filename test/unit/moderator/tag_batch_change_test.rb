require "test_helper"

module Moderator
  class TagBatchChangeTest < ActiveSupport::TestCase
    context "a tag batch change" do
      setup do
        @user = FactoryGirl.create(:moderator_user)
        CurrentUser.user = @user
        CurrentUser.ip_addr = "127.0.0.1"
        @post = FactoryGirl.create(:post, :tag_string => "aaa")
      end

      teardown do
        CurrentUser.user = nil
        CurrentUser.ip_addr = nil
      end

      should "execute" do
        tag_batch_change = TagBatchChange.new("aaa", "bbb", @user.id, "127.0.0.1")
        tag_batch_change.perform
        @post.reload
        assert_equal("bbb", @post.tag_string)
      end

      should "move saved searches" do
        ss = FactoryGirl.create(:saved_search, :user => @user, :tag_query => "123 ... 456")
        tag_batch_change = TagBatchChange.new("...", "bbb", @user.id, "127.0.0.1")
        tag_batch_change.perform
        ss.reload
        assert_equal("123 bbb 456", ss.tag_query)
      end

      should "raise an error if there is no predicate" do
        tag_batch_change = TagBatchChange.new("", "bbb", @user.id, "127.0.0.1")
        assert_raises(TagBatchChange::Error) do
          tag_batch_change.perform
        end
      end
    end
  end
end
