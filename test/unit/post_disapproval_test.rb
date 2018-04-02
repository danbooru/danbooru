require 'test_helper'

class PostDisapprovalTest < ActiveSupport::TestCase
  context "In all cases" do
    setup do
      @alice = FactoryBot.create(:moderator_user)
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
          @post = FactoryBot.create(:post)
          @user = FactoryBot.create(:user)
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

      context "when sending dmails" do
        setup do
          @uploaders = FactoryBot.create_list(:user, 2)
          @disapprovers = FactoryBot.create_list(:mod_user, 2)

          # 2 uploaders, with 2 uploads each, and 2 disapprovals on each upload.
          @uploaders.each do |uploader|
            FactoryBot.create_list(:post, 2, uploader: uploader).each do |post|
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
    end
  end
end
