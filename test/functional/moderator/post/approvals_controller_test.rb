require 'test_helper'

module Moderator
  module Post
    class ApprovalsControllerTest < ActionController::TestCase
      context "The moderator post approvals controller" do
        setup do
          @admin = FactoryGirl.create(:admin_user)
          CurrentUser.user = @admin
          CurrentUser.ip_addr = "127.0.0.1"
          
          @post = FactoryGirl.create(:post, :is_pending => true)
        end
        
        context "create action" do
          should "render" do
            post :create, {:post_id => @post.id, :format => "js"}, {:user_id => @admin.id}
            assert_response :success
            @post.reload
            assert(!@post.is_pending?)
          end
        end
      end
    end
  end
end
