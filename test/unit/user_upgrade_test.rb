require 'test_helper'

class UserUpgradeTest < ActiveSupport::TestCase
  context "UserUpgrade:" do
    context "the #process_upgrade! method" do
      context "for a self upgrade" do
        context "to Gold" do
          setup do
            @user_upgrade = create(:self_gold_upgrade)
          end

          should "update the user's level if the payment status is paid" do
            @user_upgrade.process_upgrade!("paid")

            assert_equal(User::Levels::GOLD, @user_upgrade.recipient.level)
            assert_equal("complete", @user_upgrade.status)
          end

          should "not update the user's level if the payment is unpaid" do
            @user_upgrade.process_upgrade!("unpaid")

            assert_equal(User::Levels::MEMBER, @user_upgrade.recipient.level)
            assert_equal("processing", @user_upgrade.status)
          end

          should "not update the user's level if the upgrade status is complete" do
            @user_upgrade.update!(status: "complete")
            @user_upgrade.process_upgrade!("paid")

            assert_equal(User::Levels::MEMBER, @user_upgrade.recipient.level)
            assert_equal("complete", @user_upgrade.status)
          end

          should "log an account upgrade modaction" do
            assert_difference("ModAction.user_account_upgrade.count") do
              @user_upgrade.process_upgrade!("paid")
            end
          end

          should "send the recipient a dmail" do
            assert_difference("@user_upgrade.recipient.dmails.received.count") do
              @user_upgrade.process_upgrade!("paid")
            end
          end
        end
      end
    end
  end
end
