require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  context "A user" do
    setup do
      MEMCACHE.flush_all
    end
    
    should "be authenticate" do
      @user = Factory.create(:user)
      assert(User.authenticate(@user.name, "password"), "Authentication should have succeeded")
      assert(!User.authenticate(@user.name, "password2"), "Authentication should not have succeeded")
      assert(User.authenticate_hash(@user.name, @user.password_hash), "Authentication should have succeeded")
      assert(!User.authenticate_hash(@user.name, "xxxx"), "Authentication should not have succeeded")
    end
  end
end
