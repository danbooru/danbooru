require_relative "../test_helper"

class ArtistTest < ActiveSupport::TestCase
  context "The current user" do
    should "be set only within the scope of the block" do
      user = Factory.create(:user)
      
      assert_nil(CurrentUser.user)
      assert_nil(CurrentUser.ip_addr)
      
      CurrentUser.user = user
      CurrentUser.ip_addr = "1.2.3.4"
      
      assert_equal(user.id, CurrentUser.current_user)
      assert_equal("1.2.3.4", CurrentUser.current_ip_addr)
    end
  end
end