require "test_helper"

class TagBatchChangeJobTest < ActiveJob::TestCase
  context "a tag batch change" do
    setup do
      @user = create(:moderator_user)
      @post = create(:post, :tag_string => "aaa")
    end

    context "#estimate_update_count" do
      should "find the correct count" do
        assert_equal(1, TagBatchChangeJob.estimate_update_count("aaa", "bbb"))
      end
    end

    should "execute" do
      TagBatchChangeJob.perform_now("aaa", "bbb", @user, "127.0.0.1")
      assert_equal("bbb", @post.reload.tag_string)
    end

    should "move saved searches" do
      ss = create(:saved_search, user: @user, query: "123 ... 456")
      TagBatchChangeJob.perform_now("...", "bbb", @user, "127.0.0.1")
      assert_equal("123 456 bbb", ss.reload.normalized_query)
    end

    should "move blacklists" do
      @user.update(blacklisted_tags: "123 456\n789\n")
      TagBatchChangeJob.perform_now("456", "xxx", @user, "127.0.0.1")

      assert_equal("123 xxx\n789", @user.reload.blacklisted_tags)
    end

    should "move only saved searches that match the mass update exactly" do
      ss = create(:saved_search, user: @user, query: "123 ... 456")

      TagBatchChangeJob.perform_now("1", "bbb", @user, "127.0.0.1")
      assert_equal("... 123 456", ss.reload.normalized_query, "expected '123' to remain unchanged")

      TagBatchChangeJob.perform_now("123 456", "789", @user, "127.0.0.1")
      assert_equal("... 789", ss.reload.normalized_query, "expected '123 456' to be changed to '789'")
    end

    should "log a modaction" do
      TagBatchChangeJob.perform_now("1", "2", @user, "127.0.0.1")
      assert_equal("mass_update", ModAction.last.category)
    end

    should "raise an error if there is no predicate" do
      assert_raises(TagBatchChangeJob::Error) do
        TagBatchChangeJob.perform_now("", "bbb", @user, "127.0.0.1")
      end
    end
  end
end
