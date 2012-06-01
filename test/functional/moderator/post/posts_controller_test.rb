require 'test_helper'

module Moderator
  module Post
    class PostsControllerTest < ActionController::TestCase
      context "The moderator post disapprovals controller" do
        setup do
          @admin = FactoryGirl.create(:admin_user)
          CurrentUser.user = @admin
          CurrentUser.ip_addr = "127.0.0.1"
        end
        
        context "delete action" do
          setup do
            @post = FactoryGirl.create(:post)
          end
          
          should "render" do
            post :delete, {:id => @post.id, :format => "js"}, {:user_id => @admin.id}
            assert_response :success
            @post.reload
            assert(@post.is_deleted?)
          end
        end

        context "undelete action" do
          setup do
            @post = FactoryGirl.create(:post, :is_deleted => true)
          end
          
          should "render" do
            post :undelete, {:id => @post.id, :format => "js"}, {:user_id => @admin.id}
            assert_response :success
            @post.reload
            assert(!@post.is_deleted?)
          end
        end
      end
    end
  end
end
