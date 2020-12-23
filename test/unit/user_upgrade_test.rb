require 'test_helper'

class UserUpgradeTest < ActiveSupport::TestCase
  context "UserUpgrade:" do
    context "the #process_upgrade! method" do
      setup do
        @user = create(:user)
        @user_upgrade = UserUpgrade.new(recipient: @user, purchaser: @user, level: User::Levels::GOLD)
      end

      should "update the user's level" do
        @user_upgrade.process_upgrade!
        assert_equal(User::Levels::GOLD, @user.reload.level)
      end

      should "log an account upgrade modaction" do
        assert_difference("ModAction.user_account_upgrade.count") do
          @user_upgrade.process_upgrade!
        end
      end

      should "send the user a dmail" do
        assert_difference("@user.dmails.received.count") do
          @user_upgrade.process_upgrade!
        end
      end

      context "for an upgrade for a user above Platinum level" do
        should "not demote the user" do
          @user.update!(level: User::Levels::BUILDER)

          assert_raise(User::PrivilegeError) do
            @user_upgrade.process_upgrade!
          end

          assert_equal(true, @user.reload.is_builder?)
        end
      end
    end
  end
end
