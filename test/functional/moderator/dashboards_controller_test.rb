require 'test_helper'

module Moderator
  class DashboardsControllerTest < ActionController::TestCase
    context "The moderator dashboards controller" do
      setup do
        @admin = FactoryGirl.create(:admin_user)
        CurrentUser.user = @admin
        CurrentUser.ip_addr = "127.0.0.1"
        Danbooru.config.stubs(:member_comment_time_threshold).returns(1.week.from_now)
      end

      context "show action" do
        context "for mod actions" do
          setup do
            @mod_action = FactoryGirl.create(:mod_action)
          end

          should "render" do
            assert_equal(1, ModAction.count)
            get :show, {}, {:user_id => @admin.id}
            assert_response :success
          end
        end

        context "for user feedbacks" do
          setup do
            @feedback = FactoryGirl.create(:user_feedback)
          end

          should "render" do
            assert_equal(1, UserFeedback.count)
            get :show, {}, {:user_id => @admin.id}
            assert_response :success
          end
        end

        context "for wiki pages" do
          setup do
            @wiki_page = FactoryGirl.create(:wiki_page)
          end

          should "render" do
            assert_equal(1, WikiPageVersion.count)
            get :show, {}, {:user_id => @admin.id}
            assert_response :success
          end
        end

        context "for tags and uploads" do
          setup do
            @post = FactoryGirl.create(:post)
          end

          should "render" do
            assert_equal(1, PostArchive.count)
            get :show, {}, {:user_id => @admin.id}
            assert_response :success
          end
        end

        context "for notes"do
          setup do
            @post = FactoryGirl.create(:post)
            @note = FactoryGirl.create(:note, :post_id => @post.id)
          end

          should "render" do
            assert_equal(1, NoteVersion.count)
            get :show, {}, {:user_id => @admin.id}
            assert_response :success
          end
        end

        context "for comments" do
          setup do
            @users = (0..5).map {FactoryGirl.create(:user)}

            CurrentUser.scoped(@users[0], "1.2.3.4") do
              @comment = FactoryGirl.create(:comment)
            end

            @users.each do |user|
              CurrentUser.scoped(user, "1.2.3.4") do
                @comment.vote!(-1)
              end
            end
          end

          should "render" do
            get :show, {}, {:user_id => @admin.id}
            assert_response :success
          end
        end

        context "for artists" do
          setup do
            @artist = FactoryGirl.create(:artist)
          end

          should "render" do
            get :show, {}, {:user_id => @admin.id}
            assert_equal(1, ArtistVersion.count)
            assert_response :success
          end
        end

        context "for flags" do
          setup do
            @post = FactoryGirl.create(:post)
            @post.flag!("blah")
          end

          should "render" do
            get :show, {}, {:user_id => @admin.id}
            assert_response :success
          end
        end

        context "for appeals" do
          setup do
            @post = FactoryGirl.create(:post, :is_deleted => true)
            @post.appeal!("blah")
          end

          should "render" do
            get :show, {}, {:user_id => @admin.id}
            assert_response :success
          end
        end
      end
    end
  end
end
