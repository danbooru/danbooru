require 'test_helper'

class IpBansControllerTest < ActionController::TestCase
  context "The ip bans controller" do
    setup do
      @admin = FactoryGirl.create(:admin_user)
      CurrentUser.user = @admin
      CurrentUser.ip_addr = "127.0.0.1"
    end

    context "new action" do
      should "render" do
        get :new, {}, {:user_id => @admin.id}
        assert_response :success
      end
    end

    context "create action" do
      should "create a new ip ban" do
        assert_difference("IpBan.count", 1) do
          post :create, {:ip_ban => {:ip_addr => "1.2.3.4", :reason => "xyz"}}, {:user_id => @admin.id}
        end
      end
    end

    context "index action" do
      setup do
        FactoryGirl.create(:ip_ban)
      end

      should "render" do
        get :index, {}, {:user_id => @admin.id}
        assert_response :success
      end

      context "with search parameters" do
        should "render" do
          get :index, {:search => {:ip_addr => "1.2.3.4"}}, {:user_id => @admin.id}
          assert_response :success
        end
      end
    end

    context "destroy action" do
      setup do
        @ip_ban = FactoryGirl.create(:ip_ban)
      end

      should "destroy an ip ban" do
        assert_difference("IpBan.count", -1) do
          post :destroy, {:id => @ip_ban.id, :format => "js"}, {:user_id => @admin.id}
        end
      end
    end
  end
end
