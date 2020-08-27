require "test_helper"

class TagBatchChangeJobTest < ActiveJob::TestCase
  context "a tag batch change" do
    setup do
      @user = create(:moderator_user)
      @post = create(:post, :tag_string => "aaa")
    end

    should "execute" do
      TagBatchChangeJob.perform_now("aaa", "bbb")
      assert_equal("bbb", @post.reload.tag_string)
    end

    should "log a modaction" do
      TagBatchChangeJob.perform_now("1", "2")
      assert_equal("mass_update", ModAction.last.category)
    end
  end
end
