require 'test_helper'

class CurrentUserTest < ActiveSupport::TestCase
  setup do
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  teardown do
    Thread.current[:safe_mode] = false
  end

  context ".safe_mode?" do
    should "return true if the host contains the string host" do
      req = mock()
      req.stubs(:host).returns("safebooru")
      req.stubs(:params).returns({})
      CurrentUser.set_safe_mode(req)
      assert_equal(true, CurrentUser.safe_mode?)
    end

    should "return false if the host does not contain the string host" do
      req = mock()
      req.stubs(:host).returns("danbooru")
      req.stubs(:params).returns({})
      CurrentUser.user = FactoryBot.create(:user)
      CurrentUser.set_safe_mode(req)
      assert_equal(false, CurrentUser.safe_mode?)
    end

    should "return true if the user has enabled the safe mode account setting" do
      req = mock
      req.stubs(:host).returns("danbooru")
      req.stubs(:params).returns({})

      CurrentUser.user = FactoryBot.create(:user, enable_safe_mode: true)
      CurrentUser.set_safe_mode(req)

      assert_equal(true, CurrentUser.safe_mode?)
    end
  end 

  context "The current user" do
    should "be set only within the scope of the block" do
      user = FactoryBot.create(:user)

      assert_nil(CurrentUser.user)
      assert_nil(CurrentUser.ip_addr)

      CurrentUser.user = user
      CurrentUser.ip_addr = "1.2.3.4"

      assert_not_nil(CurrentUser.user)
      assert_equal(user.id, CurrentUser.user.id)
      assert_equal("1.2.3.4", CurrentUser.ip_addr)
    end
  end

  context "A scoped current user" do
    should "reset the current user after the block has exited" do
      user1 = FactoryBot.create(:user)
      user2 = FactoryBot.create(:user)
      CurrentUser.user = user1
      CurrentUser.scoped(user2, nil) do
        assert_equal(user2.id, CurrentUser.user.id)
      end
      assert_equal(user1.id, CurrentUser.user.id)
    end

    should "reset the current user even if an exception is thrown" do
      user1 = FactoryBot.create(:user)
      user2 = FactoryBot.create(:user)
      CurrentUser.user = user1
      assert_raises(RuntimeError) do
        CurrentUser.scoped(user2, nil) do
          assert_equal(user2.id, CurrentUser.user.id)
          raise "ERROR"
        end
      end
      assert_equal(user1.id, CurrentUser.user.id)
    end
  end
end
