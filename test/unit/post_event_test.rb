require 'test_helper'

class PostEventTest < ActiveSupport::TestCase
  def setup
    @user = create(:user, created_at: 2.weeks.ago)
    @post = create(:post)
    @post_flag = create(:post_flag, creator: @user, post: @post)
    @post.update(is_deleted: true)
    @post_appeal = create(:post_appeal, creator: @user, post: @post)
  end

  context "PostEvent.find_for_post" do
    should "work" do
      results = PostEvent.find_for_post(@post.id)
      assert_equal(2, results.size)
      assert_equal("appeal", results[0].type_name)
      assert_equal("flag", results[1].type_name)
    end
  end
end
