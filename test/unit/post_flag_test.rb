require 'test_helper'

class PostFlagTest < ActiveSupport::TestCase
  context "In all cases" do
    setup do
      Timecop.travel(2.weeks.ago) do
        @alice = FactoryGirl.create(:gold_user)
      end
      CurrentUser.user = @alice
      CurrentUser.ip_addr = "127.0.0.1"
      @post = FactoryGirl.create(:post, :tag_string => "aaa")
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "a basic user" do
      setup do
        Timecop.travel(2.weeks.ago) do
          @bob = FactoryGirl.create(:user)
        end
        CurrentUser.user = @bob
      end

      should "not be able to flag more than 1 post in 24 hours" do
        @post_flag = PostFlag.new(:post => @post, :reason => "aaa", :is_resolved => false)
        @post_flag.expects(:flag_count_for_creator).returns(1)
        assert_difference("PostFlag.count", 0) do
          @post_flag.save
        end
        assert_equal(["You can flag 1 post a day"], @post_flag.errors.full_messages)
      end
    end

    context "a gold user" do
      should "not be able to flag a post more than twice" do
        assert_difference("PostFlag.count", 1) do
          @post_flag = PostFlag.create(:post => @post, :reason => "aaa", :is_resolved => false)
        end

        assert_difference("PostFlag.count", 0) do
          @post_flag = PostFlag.create(:post => @post, :reason => "aaa", :is_resolved => false)
        end

        assert_equal(["You have already flagged this post"], @post_flag.errors.full_messages)
      end

      should "not be able to flag more than 10 posts in 24 hours" do
        @post_flag = PostFlag.new(:post => @post, :reason => "aaa", :is_resolved => false)
        @post_flag.expects(:flag_count_for_creator).returns(10)
        assert_difference("PostFlag.count", 0) do
          @post_flag.save
        end
        assert_equal(["You can flag 10 posts a day"], @post_flag.errors.full_messages)
      end

      should "not be able to flag a deleted post" do
        @post.update_attribute(:is_deleted, true)
        assert_difference("PostFlag.count", 0) do
          @post_flag = PostFlag.create(:post => @post, :reason => "aaa", :is_resolved => false)
        end
        assert_equal(["Post is deleted"], @post_flag.errors.full_messages)
      end

      should "initialize its creator" do
        @post_flag = PostFlag.create(:post => @post, :reason => "aaa", :is_resolved => false)
        assert_equal(@alice.id, @post_flag.creator_id)
      end
    end
  end
end
