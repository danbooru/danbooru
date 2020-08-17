require 'test_helper'

class PostFlagTest < ActiveSupport::TestCase
  context "PostFlag: " do
    context "an approver" do
      should "be able to flag an unlimited number of posts" do
        @user = create(:user, can_approve_posts: true)

        assert_nothing_raised do
          create_list(:post_flag, 6, creator: @user, status: :pending)
        end
      end
    end

    context "a user with unlimited flags" do
      should "be able to flag an unlimited number of posts" do
        @user = create(:user)
        create_list(:post_flag, 30, status: :succeeded, creator: @user)

        assert_equal(true, @user.has_unlimited_flags?)
        assert_equal(false, @user.is_flag_limited?)

        assert_nothing_raised do
          create_list(:post_flag, 6, creator: @user, status: :pending)
        end
      end
    end

    context "a basic user" do
      should "be able to flag up to 5 posts at once" do
        @user = create(:user)
        @flags = create_list(:post_flag, 5, creator: @user, status: :pending)
        @flag = build(:post_flag, creator: @user, status: :pending)

        assert_equal(false, @flag.valid?)
        assert_equal(["have reached your flag limit"], @flag.errors[:creator])
      end

      should "have early rejected flags count against their flag limit" do
        @user = create(:user)

        create(:post_flag, creator: @user, status: :pending)
        assert_equal(1, @user.post_flags.active.count)

        create(:post_flag, creator: @user, status: :rejected)
        assert_equal(2, @user.post_flags.active.count)

        create(:post_flag, creator: @user, status: :succeeded)
        assert_equal(2, @user.post_flags.active.count)

        create(:post_flag, creator: @user, status: :rejected, created_at: 4.days.ago)
        assert_equal(2, @user.post_flags.active.count)
      end
    end

    context "a user" do
      should "not be able to flag a post more than once" do
        @user = create(:user)
        @post = create(:post)
        @post_flag = create(:post_flag, post: @post, creator: @user)
        @post_flag = build(:post_flag, post: @post, creator: @user)

        assert_equal(false, @post_flag.valid?)
        assert_equal(["have already flagged this post"], @post_flag.errors[:creator_id])
      end

      should "not be able to flag a deleted post" do
        @post = create(:post, is_deleted: true)
        @post_flag = build(:post_flag, post: @post)

        assert_equal(false, @post_flag.valid?)
        assert_equal(["Post is deleted and cannot be flagged"], @post_flag.errors.full_messages)
      end

      should "not be able to flag a pending post" do
        @post = create(:post, is_pending: true)
        @flag = build(:post_flag, post: @post)

        assert_equal(false, @flag.valid?)
        assert_equal(["Post is pending and cannot be flagged"], @flag.errors.full_messages)
      end

      should "not be able to flag a post in the cooldown period" do
        @mod = create(:moderator_user)
        @users = create_list(:user, 2)
        @post = create(:post)
        @flag1 = create(:post_flag, post: @post, creator: @users.first)
        as(@mod) { @post.approve! }

        travel_to(Danbooru.config.moderation_period.from_now - 1.minute) do
          @flag2 = build(:post_flag, post: @post, reason: "something", creator: @users.second)
          assert_equal(false, @flag2.valid?)
          assert_match(/cannot be flagged more than once/, @flag2.errors[:post].join)
        end

        travel_to(Danbooru.config.moderation_period.from_now + 1.minute) do
          @flag3 = create(:post_flag, post: @post, reason: "something", creator: @users.second)
          assert(@flag3.errors.empty?)
        end
      end
    end
  end
end
