require "test_helper"

module Moderator
  class TagBatchChangeTest < ActiveSupport::TestCase
    def setup
      super
      mock_saved_search_service!
    end

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
        ss = FactoryGirl.create(:saved_search, :user => @user, :query => "123 ... 456")
        tag_batch_change = TagBatchChange.new("...", "bbb", @user.id, "127.0.0.1")
        tag_batch_change.perform

        assert_equal("123 456 bbb", ss.reload.normalized_query)
      end

      should "move only saved searches that match the mass update exactly" do
        ss = FactoryGirl.create(:saved_search, :user => @user, :query => "123 ... 456")
        tag_batch_change = TagBatchChange.new("1", "bbb", @user.id, "127.0.0.1")
        tag_batch_change.perform

        assert_equal("... 123 456", ss.reload.normalized_query, "expected '123' to remain unchanged")

        tag_batch_change = TagBatchChange.new("123 456", "789", @user.id, "127.0.0.1")
        tag_batch_change.perform

        assert_equal("... 789", ss.reload.normalized_query, "expected '123 456' to be changed to '789'")
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
