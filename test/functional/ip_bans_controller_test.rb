require 'test_helper'

class IpBansControllerTest < ActionDispatch::IntegrationTest
  context "The ip bans controller" do
    setup do
      @admin = create(:admin_user, name: "yukari")
      @ip_ban = create(:ip_ban, ip_addr: "6.7.8.9")
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
        assert_equal("ip_ban_create", ModAction.last&.category)
      end
    end

    context "index action" do
      setup do
        CurrentUser.user = @admin
        @subnet_ban = create(:ip_ban, ip_addr: "2.0.0.0/24", creator: @admin)
        @other_ban = create(:ip_ban, reason: "malware")
      end

      should "render access denied for anonymous users" do
        get ip_bans_path
        assert_response 403
      end

      should "render" do
        get_auth ip_bans_path, @admin
        assert_response :success
      end

      should respond_to_search({}).with { [@other_ban, @subnet_ban, @ip_ban] }
      should respond_to_search(ip_addr: "6.7.8.9").with { @ip_ban }
      should respond_to_search(reason_matches: "malware").with { @other_ban }

      context "using includes" do
        should respond_to_search(creator_name: "yukari").with { @subnet_ban }
        should respond_to_search(creator: {level: User::Levels::ADMIN}).with { @subnet_ban }
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
