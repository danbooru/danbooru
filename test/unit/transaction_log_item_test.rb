require 'test_helper'

class TransactionLogItemTest < ActiveSupport::TestCase
  setup do
    @user = FactoryGirl.create(:user)
  end

  context "Promoting a user" do
    should "create a new line item in the transaction log" do
      @user.level = User::Levels::GOLD
      assert_difference("TransactionLogItem.count", 1) do
        TransactionLogItem.record_account_upgrade(@user)
      end

      item = TransactionLogItem.last
      assert_equal(@user.id, item.user_id)
      assert_equal("account_upgrade_basic_to_gold", item.category)
    end
  end

  context "Viewing the account upgrade page" do
    should "create a new line item in the transaction log" do
      assert_difference("TransactionLogItem.count", 1) do
        TransactionLogItem.record_account_upgrade_view(@user, "xxx")
      end
    end
  end
end
