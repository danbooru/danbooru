require 'test_helper'

class BanTest < ActiveSupport::TestCase
  context "A ban" do
    context "created by an admin" do
      setup do
        @banner = FactoryBot.create(:admin_user)
        CurrentUser.user = @banner
      end

      teardown do
        @banner = nil
        CurrentUser.user = nil
      end

      should "set the is_banned flag on the user" do
        user = FactoryBot.create(:user)
        ban = FactoryBot.build(:ban, :user => user, :banner => @banner)
        ban.save
        user.reload
        assert(user.is_banned?)
      end

      should "be valid" do
        user = FactoryBot.create(:user)
        ban = FactoryBot.create(:ban, :user => user, :banner => @banner)
        assert(ban.errors.empty?)
      end
    end

    context "deleting user data" do
      setup do
        @banner = create(:moderator_user)
        CurrentUser.user = @banner
        @bannee = create(:user)
      end

      should "delete the user's pending posts" do
        @pending_post = create(:post, uploader: @bannee, is_pending: true)
        @active_post = create(:post)
        create(:ban, user: @bannee, banner: @banner, delete_posts: true, post_deletion_reason: "off-topic")

        assert_equal("deleted", @pending_post.reload.status)
        assert_equal("off-topic", @pending_post.flags.last.reason)
        assert_equal("active", @active_post.reload.status)
        assert(ModAction.exists?(category: "post_delete", subject: @pending_post, creator: @banner))
      end

      should "delete the user's comments" do
        @comment = create(:comment, creator: @bannee)

        create(:ban, user: @bannee, banner: @banner, delete_comments: true)
        assert(@comment.reload.is_deleted)
        assert(ModAction.exists?(category: "comment_delete", subject: @comment, creator: @banner))
      end

      should "delete the user's forum posts" do
        @forum_topic = create(:forum_topic, creator: @bannee, original_post: create(:forum_post, creator: @bannee))
        @other_forum_topic = create(:forum_topic, original_post: create(:forum_post))
        @other_forum_post = create(:forum_post, creator: @bannee, topic: @other_forum_topic)
        create(:ban, user: @bannee, banner: @banner, delete_forum_posts: true)

        assert_equal(true, @forum_topic.reload.is_deleted)
        assert_equal(true, @forum_topic.original_post.is_deleted)
        assert_equal(false, @other_forum_topic.is_deleted)
        assert_equal(false, @other_forum_topic.original_post.is_deleted)
        assert_equal(true, @other_forum_post.reload.is_deleted)
        assert(ModAction.exists?(category: "forum_topic_delete", subject: @forum_topic, creator: @banner))
        assert(ModAction.exists?(category: "forum_post_delete", subject: @other_forum_post, creator: @banner))
      end

      should "not allow mods to delete votes" do
        @post_vote = create(:post_vote, user: @bannee)
        @ban = build(:ban, user: @bannee, banner: @banner, delete_post_votes: true)

        assert_not(@ban.valid?)
        assert_equal(["Delete post votes is not allowed by Moderator"], @ban.errors.full_messages)
        assert_not(@post_vote.reload.is_deleted)
      end

      should "allow admins to delete votes" do
        @comment_vote = create(:comment_vote, user: @bannee)
        @post_vote = create(:post_vote, user: @bannee)
        @banner = create(:admin_user)

        create(:ban, user: @bannee, banner: @banner, delete_post_votes: true, delete_comment_votes: true)
        assert(@comment_vote.reload.is_deleted)
        assert(@post_vote.reload.is_deleted)
        assert(ModAction.exists?(category: "post_vote_delete", subject: @post_vote, creator: @banner))
        assert(ModAction.exists?(category: "comment_vote_delete", subject: @comment_vote, creator: @banner))
      end

      should "not delete anything unwanted" do
        @post = create(:post, uploader: @bannee, is_pending: true)
        @comment = create(:comment, creator: @bannee)
        @forum_post = create(:forum_post, creator: @bannee)
        @post_vote = create(:post_vote, user: @bannee)
        create(:ban, user: @bannee, banner: @banner)

        assert(@post.reload.status == "pending")
        assert_not(@comment.reload.is_deleted)
        assert_not(@forum_post.reload.is_deleted)
        assert_not(@post_vote.reload.is_deleted)
      end

      should "not delete data more than 3 days old" do
        @comment = create(:comment, creator: @bannee, created_at: 4.days.ago)
        create(:ban, user: @bannee, delete_comments: true)

        assert_not(@comment.reload.is_deleted)
      end
    end

    should "initialize the expiration date" do
      user = FactoryBot.create(:user)
      admin = FactoryBot.create(:admin_user)
      CurrentUser.scoped(admin) do
        ban = FactoryBot.create(:ban, :user => user, :banner => admin)
        assert_not_nil(ban.expires_at)
      end
    end

    should "update the user's feedback" do
      user = create(:user)
      ban = create(:ban, user: user, duration: 100.years, reason: "lol")

      assert_equal(1, user.feedback.negative.count)
      assert_equal("Banned forever: lol", user.feedback.last.body)
    end

    should "send the user a dmail" do
      user = create(:user)
      ban = create(:ban, user: user, duration: 100.years, reason: "lol")

      assert_equal(1, user.dmails.count)
      assert_equal("You have been banned", user.dmails.last.title)
      assert_equal("You have been banned forever: lol", user.dmails.last.body)
    end
  end

  context "Searching for a ban" do
    should "find a given ban" do
      ban = create(:ban)

      assert_search_equals(ban, user_name: ban.user.name, banner_name: ban.banner.name, reason: ban.reason, expired: false, order: :id_desc)
    end

    context "by user id" do
      setup do
        @admin = FactoryBot.create(:admin_user)
        CurrentUser.user = @admin
        @user = FactoryBot.create(:user)
      end

      teardown do
        CurrentUser.user = nil
      end
    end
  end
end
