require 'test_helper'

class PostAppealTest < ActiveSupport::TestCase
  context "In all cases" do
    setup do
      @alice = create(:user)
    end

    context "a user" do
      setup do
        @post = FactoryBot.create(:post, :tag_string => "aaa", :is_deleted => true)
      end

      should "not be able to appeal a post more than twice" do
        @post_appeal = create(:post_appeal, post: @post, creator: @alice)
        @post_appeal = build(:post_appeal, post: @post, creator: @alice)

        assert_equal(false, @post_appeal.valid?)
        assert_includes(@post_appeal.errors.full_messages, "You have already appealed this post")
      end

      should "not be able to appeal more than 1 post in 24 hours" do
        @post_appeal = create(:post_appeal, post: @post, creator: @alice)
        @post_appeal = build(:post_appeal, post: create(:post, is_deleted: true), creator: @alice)

        assert_equal(false, @post_appeal.valid?)
        assert_equal(["You can appeal at most 1 post a day"], @post_appeal.errors.full_messages)
      end

      should "not be able to appeal an active post" do
        @post.update_attribute(:is_deleted, false)
        @post_appeal = build(:post_appeal, post: @post, creator: @alice)

        assert_equal(false, @post_appeal.valid?)
        assert_equal(["Post is active"], @post_appeal.errors.full_messages)
      end
    end
  end
end
