require 'test_helper'

class PostAppealTest < ActiveSupport::TestCase
  context "In all cases" do
    setup do
      @alice = FactoryBot.create(:user)
      CurrentUser.user = @alice
      CurrentUser.ip_addr = "127.0.0.1"
      Danbooru.config.stubs(:max_appeals_per_day).returns(5)
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "a user" do
      setup do
        @post = FactoryBot.create(:post, :tag_string => "aaa", :is_deleted => true)
      end

      should "not be able to appeal a post more than twice" do
        assert_difference("PostAppeal.count", 1) do
          @post_appeal = PostAppeal.create(:post => @post, :reason => "aaa")
        end

        assert_difference("PostAppeal.count", 0) do
          @post_appeal = PostAppeal.create(:post => @post, :reason => "aaa")
        end

        assert_equal(["You have already appealed this post"], @post_appeal.errors.full_messages)
      end

      should "not be able to appeal more than 5 posts in 24 hours" do
        @post_appeal = PostAppeal.new(:post => @post, :reason => "aaa")
        @post_appeal.expects(:appeal_count_for_creator).returns(5)
        assert_difference("PostAppeal.count", 0) do
          @post_appeal.save
        end
        assert_equal(["You can appeal at most 5 post a day"], @post_appeal.errors.full_messages)
      end

      should "not be able to appeal an active post" do
        @post.update_attribute(:is_deleted, false)
        assert_difference("PostAppeal.count", 0) do
          @post_appeal = PostAppeal.create(:post => @post, :reason => "aaa")
        end
        assert_equal(["Post is active"], @post_appeal.errors.full_messages)
      end

      should "initialize its creator" do
        @post_appeal = PostAppeal.create(:post => @post, :reason => "aaa")
        assert_equal(@alice.id, @post_appeal.creator_id)
      end
    end
  end
end
