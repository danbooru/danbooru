require 'test_helper'

class PostDisapprovalTest < ActiveSupport::TestCase
  context "In all cases" do
    setup do
      @alice = FactoryBot.create(:moderator_user, name: "alice")
      CurrentUser.user = @alice
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "A post disapproval" do
      setup do
        @post_1 = FactoryBot.create(:post, :is_pending => true)
        @post_2 = FactoryBot.create(:post, :is_pending => true)
      end

      should "not allow blank messages" do
        @post_disapproval = create(:post_disapproval, post: @post_1, message: "")
        assert_equal(nil, @post_disapproval.message)
      end

      context "made by alice" do
        setup do
          @disapproval = create(:post_disapproval, user: @alice, post: @post_1)
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
            @brittony = FactoryBot.create(:moderator_user)
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
          @post = FactoryBot.create(:post, is_pending: true)
          @user = FactoryBot.create(:user)
          @disapproval = create(:post_disapproval, user: @user, post: @post, created_at: 2.months.ago)
        end

        should "be pruned" do
          assert_difference("PostDisapproval.count", -1) do
            PostDisapproval.prune!
          end
        end
      end

      context "when sending dmails" do
        setup do
          @uploaders = FactoryBot.create_list(:user, 2, created_at: 2.weeks.ago)
          @disapprovers = FactoryBot.create_list(:mod_user, 2)

          # 2 uploaders, with 2 uploads each, and 2 disapprovals on each upload.
          @uploaders.each do |uploader|
            FactoryBot.create_list(:post, 2, is_pending: true, uploader: uploader).each do |post|
              FactoryBot.create(:post_disapproval, post: post, user: @disapprovers[0])
              FactoryBot.create(:post_disapproval, post: post, user: @disapprovers[1])
            end
          end
        end

        should "dmail the uploaders" do
          bot = FactoryBot.create(:user)
          User.stubs(:system).returns(bot)

          assert_difference(["@uploaders[0].dmails.count", "@uploaders[1].dmails.count"], 1) do
            PostDisapproval.dmail_messages!
          end

          assert(@uploaders[0].dmails.exists?(from: bot, to: @uploaders[0]))
          assert(@uploaders[1].dmails.exists?(from: bot, to: @uploaders[1]))
        end
      end

      context "#search" do
        should "work" do
          disapproval1 = FactoryBot.create(:post_disapproval, user: @alice, post: @post_1, reason: "breaks_rules")
          disapproval2 = FactoryBot.create(:post_disapproval, user: @alice, post: @post_2, reason: "poor_quality", message: "bad anatomy")

          assert_equal([disapproval1.id], PostDisapproval.search(reason: "breaks_rules").pluck(:id))
          assert_equal([disapproval2.id], PostDisapproval.search(message: "bad anatomy").pluck(:id))
          assert_equal([disapproval2.id, disapproval1.id], PostDisapproval.search(creator_name: "alice").pluck(:id))
        end
      end
    end
  end
end
