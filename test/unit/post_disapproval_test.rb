require "test_helper"

class PostDisapprovalTest < ActiveSupport::TestCase
  context "In all cases" do
    setup do
      @alice = FactoryBot.create(:moderator_user)
      CurrentUser.user = @alice
    end

    teardown do
      CurrentUser.user = nil
    end

    context "a post disapproval" do
      setup do
        @post_1 = FactoryBot.create(:post, :is_pending => true)
        @post_2 = FactoryBot.create(:post, :is_pending => true)
      end

      should "not allow blank messages" do
        @post_disapproval = create(:post_disapproval, post: @post_1, message: "")
        assert_nil(@post_disapproval.message)
      end

      context "made by alice" do
        setup do
          @disapproval = create(:post_disapproval, user: @alice, post: @post_1)
        end

        context "when the current user is alice" do
          should "remove the associated post from alice's moderation queue" do
            assert_not(Post.available_for_moderation(@alice, hidden: false).map(&:id).include?(@post_1.id))
            assert(Post.available_for_moderation(@alice, hidden: false).map(&:id).include?(@post_2.id))
          end
        end

        context "when the current user is not the disapprover" do
          should "not remove the associated post from the disapprover's moderation queue" do
            @mod = create(:moderator_user)

            assert(Post.available_for_moderation(@mod, hidden: false).map(&:id).include?(@post_1.id))
            assert(Post.available_for_moderation(@mod, hidden: false).map(&:id).include?(@post_2.id))
          end
        end
      end

      context "when pruning" do
        should "prune old disapprovals" do
          @user = FactoryBot.create(:user)
          @post = FactoryBot.create(:post, is_pending: true)
          create(:post_disapproval, user: @user, post: @post, created_at: 2.months.ago)
          assert_difference("PostDisapproval.count", -1) do
            PostDisapproval.prune!
          end
        end

        should "not prune recent disapprovals" do
          @user = FactoryBot.create(:user)
          @post = FactoryBot.create(:post, is_pending: true)
          @disapproval = create(:post_disapproval, user: @user, post: @post, created_at: 7.days.ago)
          assert_no_difference("PostDisapproval.count") do
            PostDisapproval.prune!
          end
        end
      end

      context "#search" do
        should "work" do
          @approver = create(:approver)
          @post1 = create(:post, is_pending: true)
          @post2 = create(:post, is_pending: true)
          disapproval1 = FactoryBot.create(:post_disapproval, user: @approver, post: @post1, reason: "breaks_rules")
          disapproval2 = FactoryBot.create(:post_disapproval, user: @approver, post: @post2, reason: "poor_quality", message: "bad anatomy")

          assert_search_equals([disapproval1], reason: "breaks_rules")
          assert_search_equals([disapproval2], message: "bad anatomy")
        end
      end
    end

    context "post deletions" do
      should "not prune disapprovals" do
        @post = create(:post, is_pending: true)
        @user = create(:moderator_user)
        create(:post_disapproval, user: @user, post: @post, message: "test")
        assert_equal(1, PostDisapproval.where(post: @post).size)
        @post.delete!("blah", user: @user)
        assert_equal(1, PostDisapproval.where(post: @post).size)
      end
    end

    context "post appeals" do
      should "prune disapprovals" do
        @post = create(:post, is_pending: true)
        @user = create(:moderator_user)
        create(:post_disapproval, user: @user, post: @post, message: "test")
        assert_equal(1, PostDisapproval.where(post: @post).size)
        @post.delete!("blah", user: @user)

        create(:post_appeal, post: @post, creator: @user)

        assert_equal(0, PostDisapproval.where(post: @post).size)
      end
    end

    context "post flags" do
      should "prune disapprovals" do
        @post = create(:post, is_pending: true)
        @user = create(:moderator_user)
        create(:post_disapproval, user: @user, post: @post, message: "test")
        assert_equal(1, PostDisapproval.where(post: @post).size)

        create(:post_approval, post: @post, user: @user)
        create(:post_flag, post: @post, creator: @user)

        assert_equal(0, PostDisapproval.where(post: @post).size)
      end
    end
  end
end
