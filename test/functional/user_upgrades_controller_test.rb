require 'test_helper'

class UserUpgradesControllerTest < ActionDispatch::IntegrationTest
  setup do
    StripeMock.start
  end

  teardown do
    StripeMock.stop
  end

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
      setup do
        @user = create(:user)
        @token = StripeMock.generate_card_token
      end

      context "a self upgrade" do
        should "upgrade a Member to Gold" do
          post_auth user_upgrade_path, @user, params: { stripeToken: @token, desc: "Upgrade to Gold" }

          assert_redirected_to user_upgrade_path
          assert_equal(true, @user.reload.is_gold?)
        end

        should "upgrade a Member to Platinum" do
          post_auth user_upgrade_path, @user, params: { stripeToken: @token, desc: "Upgrade to Platinum" }

          assert_redirected_to user_upgrade_path
          assert_equal(true, @user.reload.is_platinum?)
        end

        should "upgrade a Gold user to Platinum" do
          @user.update!(level: User::Levels::GOLD)
          post_auth user_upgrade_path, @user, params: { stripeToken: @token, desc: "Upgrade Gold to Platinum" }

          assert_redirected_to user_upgrade_path
          assert_equal(true, @user.reload.is_platinum?)
        end

        should "log an account upgrade modaction" do
          assert_difference("ModAction.user_account_upgrade.count") do
            post_auth user_upgrade_path, @user, params: { stripeToken: @token, desc: "Upgrade to Gold" }
          end
        end

        should "send the user a dmail" do
          assert_difference("@user.dmails.received.count") do
            post_auth user_upgrade_path, @user, params: { stripeToken: @token, desc: "Upgrade to Gold" }
          end
        end
      end

      context "a gifted upgrade" do
        should "upgrade the user to Gold" do
          @other_user = create(:user)
          post_auth user_upgrade_path, @user, params: { stripeToken: @token, desc: "Upgrade to Gold", user_id: @other_user.id }

          assert_redirected_to user_upgrade_path(user_id: @other_user.id)
          assert_equal(true, @other_user.reload.is_gold?)
          assert_equal(false, @user.reload.is_gold?)
        end
      end

      context "an upgrade with a missing Stripe token" do
        should "not upgrade the user" do
          post_auth user_upgrade_path, @user, params: { desc: "Upgrade to Gold" }

          assert_response :success
          assert_equal(true, @user.reload.is_member?)
        end
      end

      context "an upgrade with an invalid Stripe token" do
        should "not upgrade the user" do
          post_auth user_upgrade_path, @user, params: { stripeToken: "garbage", desc: "Upgrade to Gold" }

          assert_redirected_to user_upgrade_path
          assert_equal(true, @user.reload.is_member?)
        end
      end

      context "an upgrade with an credit card that is declined" do
        should "not upgrade the user" do
          StripeMock.prepare_card_error(:card_declined)
          post_auth user_upgrade_path, @user, params: { stripeToken: @token, desc: "Upgrade to Gold" }

          assert_redirected_to user_upgrade_path
          assert_equal(true, @user.reload.is_member?)
        end
      end

      context "an upgrade with an credit card that is expired" do
        should "not upgrade the user" do
          StripeMock.prepare_card_error(:expired_card)
          post_auth user_upgrade_path, @user, params: { stripeToken: @token, desc: "Upgrade to Gold" }

          assert_redirected_to user_upgrade_path
          assert_equal(true, @user.reload.is_member?)
        end
      end
    end
  end
end
