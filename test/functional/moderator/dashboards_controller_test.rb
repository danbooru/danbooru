require 'test_helper'

module Moderator
  class DashboardsControllerTest < ActionController::TestCase
    context "The moderator dashboards controller" do
      setup do
        @admin = Factory.create(:admin_user)
        CurrentUser.user = @admin
        CurrentUser.ip_addr = "127.0.0.1"
        Danbooru.config.stubs(:member_comment_time_threshold).returns(1.week.from_now)
      end

      context "show action" do
        context "for mod actions" do
          setup do
            @mod_action = Factory.create(:mod_action)
          end
          
          should "render" do
            assert_equal(1, ModAction.count)
            get :show, {}, {:user_id => @admin.id}
            assert_response :success
          end
        end
        
        context "for user feedbacks" do
          setup do
            @feedback = Factory.create(:user_feedback)
          end
          
          should "render" do
            assert_equal(1, UserFeedback.count)
            get :show, {}, {:user_id => @admin.id}
            assert_response :success
          end
        end
        
        context "for wiki pages" do
          setup do
            @wiki_page = Factory.create(:wiki_page)
          end
          
          should "render" do
            assert_equal(1, WikiPageVersion.count)
            get :show, {}, {:user_id => @admin.id}
            assert_response :success
          end
        end
        
        context "for tags and uploads" do
          setup do
            @post = Factory.create(:post)
          end
          
          should "render" do
            assert_equal(1, PostVersion.count)
            get :show, {}, {:user_id => @admin.id}
            assert_response :success
          end
        end
        
        context "for notes"do
          setup do
            @post = Factory.create(:post)
            @note = Factory.create(:note, :post_id => @post.id)
          end
          
          should "render" do
            assert_equal(1, NoteVersion.count)
            get :show, {}, {:user_id => @admin.id}
            assert_response :success
          end
        end
      
        context "for comments" do
          setup do
            @users = (0..5).map {Factory.create(:user)}

            CurrentUser.scoped(@users[0], "1.2.3.4") do
              @comment = Factory.create(:comment)
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
            @artist = Factory.create(:artist)
          end
          
          should "render" do
            get :show, {}, {:user_id => @admin.id}
            assert_equal(1, ArtistVersion.count)
            assert_response :success
          end
        end
        
        context "for flags" do
          setup do
            @post = Factory.create(:post)
            @post.flag!("blah")
          end

          should "render" do
            get :show, {}, {:user_id => @admin.id}
            assert_response :success
          end
        end
        
        context "for appeals" do
          setup do
            @post = Factory.create(:post, :is_deleted => true)
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
