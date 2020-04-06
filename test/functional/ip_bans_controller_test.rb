require 'test_helper'

class IpBansControllerTest < ActionDispatch::IntegrationTest
  context "The ip bans controller" do
    setup do
      @admin = create(:admin_user)
      @ip_ban = create(:ip_ban)
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
          assert_response :redirect
        end
      end

      should "log a mod action" do
        post_auth ip_bans_path, @admin, params: { ip_ban: { ip_addr: "1.2.3.4", reason: "xyz" }}
        assert_equal("ip_ban_create", ModAction.last.category)
      end
    end

    context "index action" do
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

    context "update action" do
      should "mark an ip ban as deleted" do
        put_auth ip_ban_path(@ip_ban), @admin, params: { ip_ban: { is_deleted: true }, format: "js" }
        assert_response :success
        assert_equal(true, @ip_ban.reload.is_deleted)
        assert_equal("ip_ban_delete", ModAction.last.category)
      end
    end
  end
end
