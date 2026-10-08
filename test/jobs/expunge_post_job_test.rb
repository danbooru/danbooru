require "test_helper"

class ExpungePostJobTest < ActiveJob::TestCase
  context "ExpungePostJob" do
    should "expunge the post" do
      user = create(:admin_user)
      post = create(:post_with_file)

      ExpungePostJob.perform_now(post: post, user: user)

      assert_equal(false, Post.exists?(post.id))
      assert_equal("post_permanent_delete", ModAction.last.category)
      assert_equal(user, ModAction.last.creator)
    end
  end
end
