require 'test_helper'

class PostFlagTest < ActiveSupport::TestCase
  context "In all cases" do
    setup do
      travel_to(2.weeks.ago) do
        @alice = create(:gold_user)
      end
      as(@alice) do
        @post = create(:post, tag_string: "aaa", uploader: @alice)
      end
    end

    context "a basic user" do
      should "not be able to flag more than 1 post in 24 hours" do
        @bob = create(:user, created_at: 2.weeks.ago)
        @post_flag = build(:post_flag, creator: @bob)
        @post_flag.expects(:flag_count_for_creator).returns(1)

        assert_equal(false, @post_flag.valid?)
        assert_equal(["You can flag 1 post a day"], @post_flag.errors.full_messages)
      end
    end

    context "a gold user" do
      setup do
        @bob = create(:gold_user, created_at: 1.month.ago)
      end

      should "not be able to flag a post more than twice" do
        @post_flag = create(:post_flag, post: @post, creator: @bob)
        @post_flag = build(:post_flag, post: @post, creator: @bob)

        assert_equal(false, @post_flag.valid?)
        assert_equal(["have already flagged this post"], @post_flag.errors[:creator_id])
      end

      should "not be able to flag more than 10 posts in 24 hours" do
        @post_flag = build(:post_flag, post: @post, creator: @bob)
        @post_flag.expects(:flag_count_for_creator).returns(10)

        assert_difference(-> { PostFlag.count }, 0) do
          @post_flag.save
        end

        assert_equal(["You can flag 10 posts a day"], @post_flag.errors.full_messages)
      end

      should "not be able to flag a deleted post" do
        as(@alice) do
          @post.update(is_deleted: true)
        end

        @post_flag = build(:post_flag, post: @post, creator: @bob)
        @post_flag.save
        assert_equal(["Post is deleted"], @post_flag.errors.full_messages)
      end

      should "not be able to flag a pending post" do
        as(@alice) do
          @post.update(is_pending: true)
        end
        @flag = @post.flags.create(reason: "test", creator: @bob)

        assert_equal(["Post is pending and cannot be flagged"], @flag.errors.full_messages)
      end

      should "not be able to flag a post in the cooldown period" do
        @mod = create(:moderator_user)

        travel_to(2.weeks.ago) do
          @users = FactoryBot.create_list(:user, 2)
        end

        @flag1 = create(:post_flag, post: @post, reason: "something", creator: @users.first)

        as(@mod) do
          @post.approve!
        end

        travel_to(PostFlag::COOLDOWN_PERIOD.from_now - 1.minute) do
          @flag2 = build(:post_flag, post: @post, reason: "something", creator: @users.second)
          assert_equal(false, @flag2.valid?)
          assert_match(/cannot be flagged more than once/, @flag2.errors[:post].join)
        end

        travel_to(PostFlag::COOLDOWN_PERIOD.from_now + 1.minute) do
          @flag3 = create(:post_flag, post: @post, reason: "something", creator: @users.second)
          assert(@flag3.errors.empty?)
        end
      end

      should "initialize its creator" do
        @post_flag = create(:post_flag, creator: @alice)
        assert_equal(@alice.id, @post_flag.creator_id)
      end
    end
  end
end
