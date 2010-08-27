require_relative '../test_helper'

class JanitorTrialTest < ActiveSupport::TestCase
  setup do
    user = Factory.create(:user)
    CurrentUser.user = user
    CurrentUser.ip_addr = "127.0.0.1"
    MEMCACHE.flush_all
  end
  
  teardown do
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end
  
  should "create a dmail when testing a new janitor" do
    admin = Factory.create(:admin_user)
    user = Factory.create(:user)
    assert_difference("Dmail.count", 2) do
      JanitorTrial.create(:user_id => user.id)
    end
  end
end
