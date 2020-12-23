require 'test_helper'

class UserUpgradesControllerTest < ActionDispatch::IntegrationTest
  context "The user upgrades controller" do
    context "new action" do
      should "render" do
        get new_user_upgrade_path
        assert_response :success
      end
    end

    context "show action" do
      should "render" do
        get_auth user_upgrade_path, create(:user)
        assert_response :success
      end
    end

    context "create action" do
      mock_stripe!

      context "for a self upgrade to Gold" do
        should "redirect the user to the Stripe checkout page" do
          user = create(:member_user)
          post_auth user_upgrade_path(user_id: user.id), user, params: { level: User::Levels::GOLD }, xhr: true

          assert_response :success
        end
      end

      context "for a gifted upgrade to Gold" do
        should "redirect the user to the Stripe checkout page" do
          recipient = create(:member_user)
          purchaser = create(:member_user)
          post_auth user_upgrade_path(user_id: recipient.id), purchaser, params: { level: User::Levels::GOLD }, xhr: true

          assert_response :success
        end
      end
    end
  end
end
