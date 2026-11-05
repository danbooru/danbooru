require "test_helper"

class UpgradeCodeTest < ActiveSupport::TestCase
  context "UpgradeCode" do
    context "#redeem!" do
      should "not allow a code to be redeemed twice by concurrent requests" do
        code = create(:upgrade_code, status: :unredeemed)
        stale_code = UpgradeCode.find(code.id)
        user1 = create(:user)
        user2 = create(:user)

        code.redeem!(user1)

        assert_raises(UpgradeCode::RedeemedCodeError) { stale_code.redeem!(user2) }
        assert_equal(true, user1.reload.is_gold?)
        assert_equal(false, user2.reload.is_gold?)
        assert_equal(user1, code.reload.redeemer)
      end
    end
  end
end
