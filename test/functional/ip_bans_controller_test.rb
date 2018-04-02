require 'test_helper'

class IpBansControllerTest < ActionDispatch::IntegrationTest
  context "The ip bans controller" do
    setup do
      @admin = create(:admin_user)
    end

    context "new action" do
      should "render" do
        get_auth new_ip_ban_path, @admin
        assert_response :success
      end
    end

    context "create action" do
      should "create a new ip ban" do
        assert_difference("IpBan.count", 1) do
          post_auth ip_bans_path, @admin, params: {:ip_ban => {:ip_addr => "1.2.3.4", :reason => "xyz"}}
        end
      end
    end

    context "index action" do
      setup do
        as(@admin) do
          create(:ip_ban)
        end
      end

      should "render" do
        get_auth ip_bans_path, @admin
        assert_response :success
      end

      context "with search parameters" do
        should "render" do
          get_auth ip_bans_path, @admin, params: {:search => {:ip_addr => "1.2.3.4"}}
          assert_response :success
        end
      end
    end

    context "destroy action" do
      setup do
        as(@admin) do
          @ip_ban = create(:ip_ban)
        end
      end

      should "destroy an ip ban" do
        assert_difference("IpBan.count", -1) do
          delete_auth ip_ban_path(@ip_ban), @admin, params: {:format => "js"}
        end
      end
    end
  end
end
