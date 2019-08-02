require 'test_helper'

class ModActionTest < ActiveSupport::TestCase
  context "A mod action" do
    setup do
      @user = FactoryBot.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end

    should "hide ip addresses from non-moderators in ip ban modactions" do
      FactoryBot.create(:ip_ban, ip_addr: "1.1.1.1", reason: "test")

      assert_equal(1, ModAction.count)
      assert_equal("#{@user.name} created ip ban", ModAction.last.filtered_description)
      assert_equal("#{@user.name} created ip ban", ModAction.last.as_json["description"])
    end
  end
end
