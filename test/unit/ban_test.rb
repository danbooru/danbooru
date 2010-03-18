require File.dirname(__FILE__) + '/../test_helper'

class BanTest < ActiveSupport::TestCase
  context "A ban" do
    context "created by an admin" do
      setup do
        @banner = Factory.create(:admin_user)
      end
      
      teardown do
        @banner = nil
      end
      
      should "not be valid against another admin" do
        user = Factory.create(:admin_user)
        ban = Factory.build(:ban, :user => user, :banner => @banner)
        ban.save
        assert(ban.errors.any?)
      end
      
      should "be valid against anyone who is not an admin" do
        user = Factory.create(:moderator_user)
        ban = Factory.create(:ban, :user => user, :banner => @banner)
        assert(ban.errors.empty?)

        user = Factory.create(:janitor_user)
        ban = Factory.create(:ban, :user => user, :banner => @banner)
        assert(ban.errors.empty?)

        user = Factory.create(:contributor_user)
        ban = Factory.create(:ban, :user => user, :banner => @banner)
        assert(ban.errors.empty?)

        user = Factory.create(:privileged_user)
        ban = Factory.create(:ban, :user => user, :banner => @banner)
        assert(ban.errors.empty?)

        user = Factory.create(:user)
        ban = Factory.create(:ban, :user => user, :banner => @banner)
        assert(ban.errors.empty?)
      end
    end
    
    context "created by a moderator" do
      setup do
        @banner = Factory.create(:moderator_user)
      end
      
      teardown do
        @banner = nil
      end
      
      should "not be valid against an admin or moderator" do
        user = Factory.create(:admin_user)
        ban = Factory.build(:ban, :user => user, :banner => @banner)
        ban.save
        assert(ban.errors.any?)

        user = Factory.create(:moderator_user)
        ban = Factory.build(:ban, :user => user, :banner => @banner)
        ban.save
        assert(ban.errors.any?)
      end
      
      should "be valid against anyone who is not an admin or a moderator" do
        user = Factory.create(:janitor_user)
        ban = Factory.create(:ban, :user => user, :banner => @banner)
        assert(ban.errors.empty?)

        user = Factory.create(:contributor_user)
        ban = Factory.create(:ban, :user => user, :banner => @banner)
        assert(ban.errors.empty?)

        user = Factory.create(:privileged_user)
        ban = Factory.create(:ban, :user => user, :banner => @banner)
        assert(ban.errors.empty?)

        user = Factory.create(:user)
        ban = Factory.create(:ban, :user => user, :banner => @banner)
        assert(ban.errors.empty?)
      end
    end
    
    context "created by a janitor" do
      setup do
        @banner = Factory.create(:janitor_user)        
      end
      
      teardown do
        @banner = nil
      end
      
      should "always be invalid" do
        user = Factory.create(:admin_user)
        ban = Factory.build(:ban, :user => user, :banner => @banner)
        ban.save
        assert(ban.errors.any?)

        user = Factory.create(:moderator_user)
        ban = Factory.build(:ban, :user => user, :banner => @banner)
        ban.save
        assert(ban.errors.any?)

        user = Factory.create(:janitor_user)
        ban = Factory.build(:ban, :user => user, :banner => @banner)
        ban.save
        assert(ban.errors.any?)

        user = Factory.create(:contributor_user)
        ban = Factory.build(:ban, :user => user, :banner => @banner)
        ban.save
        assert(ban.errors.any?)

        user = Factory.create(:privileged_user)
        ban = Factory.build(:ban, :user => user, :banner => @banner)
        ban.save
        assert(ban.errors.any?)

        user = Factory.create(:user)
        ban = Factory.build(:ban, :user => user, :banner => @banner)
        ban.save
        assert(ban.errors.any?)
      end
    end

    should "initialize the expiration date" do
      user = Factory.create(:user)
      admin = Factory.create(:admin_user)
      ban = Factory.create(:ban, :user => user, :banner => admin)
      assert_not_nil(ban.expires_at)
    end
    
    should "update the user's feedback" do
      user = Factory.create(:user)
      admin = Factory.create(:admin_user)
      assert(user.feedback.empty?)
      ban = Factory.create(:ban, :user => user, :banner => admin)
      assert(!user.feedback.empty?)
      assert(!user.feedback.last.is_positive?)
    end
  end

  context "Searching for a ban" do
    context "by user id" do
      should "not return expired bans" do
        admin = Factory.create(:admin_user)

        user = Factory.create(:user)
        ban = Factory.create(:ban, :user => user, :banner => admin, :duration => -1)
        assert(!Ban.is_user_banned?(user))

        user = Factory.create(:user)
        ban = Factory.create(:ban, :user => user, :banner => admin, :duration => 1)
        assert(Ban.is_user_banned?(user))
      end
    end    
  end
end
