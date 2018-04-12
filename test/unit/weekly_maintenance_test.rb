require 'test_helper'

class WeeklyMaintenanceTest < ActiveSupport::TestCase
  context "weekly maintenance" do
    should "prune password resets" do
      @user = FactoryBot.create(:user, email: "test@example.com")
      @nonce = FactoryBot.create(:user_password_reset_nonce, email: "test@example.com", created_at: 1.month.ago)

      WeeklyMaintenance.new.run
      assert_equal(0, UserPasswordResetNonce.count)
    end
  end
end
