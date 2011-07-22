require 'test_helper'

module Moderator
  module Post
    class DashboardsControllerTest < ActionController::TestCase
      context "The moderator post dashboards controller" do
        setup do
          @admin = Factory.create(:admin_user)
          CurrentUser.user = @admin
          CurrentUser.ip_addr = "127.0.0.1"
          
          @post = Factory.create(:post, :is_pending => true)
        end
        
        context "show action" do
          should "render" do
            get :show, {}, {:user_id => @admin.id}
            assert_response :success
          end
        end
      end
    end
  end
end
