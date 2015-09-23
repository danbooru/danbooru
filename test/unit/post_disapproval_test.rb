require 'test_helper'

class PostDisapprovalTest < ActiveSupport::TestCase
  context "In all cases" do
    setup do
      @alice = FactoryGirl.create(:moderator_user)
      CurrentUser.user = @alice
      CurrentUser.ip_addr = "127.0.0.1"
      MEMCACHE.flush_all
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "A post disapproval" do
      setup do
        @post_1 = FactoryGirl.create(:post, :is_pending => true)
        @post_2 = FactoryGirl.create(:post, :is_pending => true)
      end

      context "made by alice" do
        setup do
          @disapproval = PostDisapproval.create(:user => @alice, :post => @post_1)
        end

        context "when the current user is alice" do
          setup do
            CurrentUser.user = @alice
          end

          should "remove the associated post from alice's moderation queue" do
            assert(!Post.available_for_moderation(false).map(&:id).include?(@post_1.id))
            assert(Post.available_for_moderation(false).map(&:id).include?(@post_2.id))
          end
        end

        context "when the current user is brittony" do
          setup do
            @brittony = FactoryGirl.create(:moderator_user)
            CurrentUser.user = @brittony
          end

          should "not remove the associated post from brittony's moderation queue" do
            assert(Post.available_for_moderation(false).map(&:id).include?(@post_1.id))
            assert(Post.available_for_moderation(false).map(&:id).include?(@post_2.id))
          end
        end
      end

      context "for a post that has been approved" do
        setup do
          @post = FactoryGirl.create(:post)
          @user = FactoryGirl.create(:user)
          Timecop.travel(2.months.ago) do
            @disapproval = PostDisapproval.create(:user => @user, :post => @post)
          end
        end

        should "be pruned" do
          assert_difference("PostDisapproval.count", -1) do
            PostDisapproval.prune!
          end
        end
      end
    end
  end
end
