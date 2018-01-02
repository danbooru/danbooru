require 'test_helper'

class BanTest < ActiveSupport::TestCase
  context "A ban" do
    context "created by an admin" do
      setup do
        @banner = FactoryGirl.create(:admin_user)
        CurrentUser.user = @banner
        CurrentUser.ip_addr = "127.0.0.1"
      end

      teardown do
        @banner = nil
        CurrentUser.user = nil
        CurrentUser.ip_addr = nil
      end

      should "set the is_banned flag on the user" do
        user = FactoryGirl.create(:user)
        ban = FactoryGirl.build(:ban, :user => user, :banner => @banner)
        ban.save
        user.reload
        assert(user.is_banned?)
      end

      should "not be valid against another admin" do
        user = FactoryGirl.create(:admin_user)
        ban = FactoryGirl.build(:ban, :user => user, :banner => @banner)
        ban.save
        assert(ban.errors.any?)
      end

      should "be valid against anyone who is not an admin" do
        user = FactoryGirl.create(:moderator_user)
        ban = FactoryGirl.create(:ban, :user => user, :banner => @banner)
        assert(ban.errors.empty?)

        user = FactoryGirl.create(:contributor_user)
        ban = FactoryGirl.create(:ban, :user => user, :banner => @banner)
        assert(ban.errors.empty?)

        user = FactoryGirl.create(:gold_user)
        ban = FactoryGirl.create(:ban, :user => user, :banner => @banner)
        assert(ban.errors.empty?)

        user = FactoryGirl.create(:user)
        ban = FactoryGirl.create(:ban, :user => user, :banner => @banner)
        assert(ban.errors.empty?)
      end
    end

    context "created by a moderator" do
      setup do
        @banner = FactoryGirl.create(:moderator_user)
        CurrentUser.user = @banner
        CurrentUser.ip_addr = "127.0.0.1"
      end

      teardown do
        @banner = nil
        CurrentUser.user = nil
        CurrentUser.ip_addr = nil
      end

      should "not be valid against an admin or moderator" do
        user = FactoryGirl.create(:admin_user)
        ban = FactoryGirl.build(:ban, :user => user, :banner => @banner)
        ban.save
        assert(ban.errors.any?)

        user = FactoryGirl.create(:moderator_user)
        ban = FactoryGirl.build(:ban, :user => user, :banner => @banner)
        ban.save
        assert(ban.errors.any?)
      end

      should "be valid against anyone who is not an admin or a moderator" do
        user = FactoryGirl.create(:contributor_user)
        ban = FactoryGirl.create(:ban, :user => user, :banner => @banner)
        assert(ban.errors.empty?)

        user = FactoryGirl.create(:gold_user)
        ban = FactoryGirl.create(:ban, :user => user, :banner => @banner)
        assert(ban.errors.empty?)

        user = FactoryGirl.create(:user)
        ban = FactoryGirl.create(:ban, :user => user, :banner => @banner)
        assert(ban.errors.empty?)
      end
    end

    should "initialize the expiration date" do
      user = FactoryGirl.create(:user)
      admin = FactoryGirl.create(:admin_user)
      CurrentUser.scoped(admin) do
        ban = FactoryGirl.create(:ban, :user => user, :banner => admin)
        assert_not_nil(ban.expires_at)
      end
    end

    should "update the user's feedback" do
      user = FactoryGirl.create(:user)
      admin = FactoryGirl.create(:admin_user)
      assert(user.feedback.empty?)
      CurrentUser.scoped(admin) do
        FactoryGirl.create(:ban, :user => user, :banner => admin)
      end
      assert(!user.feedback.empty?)
      assert_equal("negative", user.feedback.last.category)
    end
  end

  context "Searching for a ban" do
    should "find a given ban" do
      CurrentUser.user = FactoryGirl.create(:admin_user)
      CurrentUser.ip_addr = "127.0.0.1"

      user = FactoryGirl.create(:user)
      ban = FactoryGirl.create(:ban, user: user)
      params = {
        user_name: user.name,
        banner_name: ban.banner.name,
        reason: ban.reason,
        expired: false,
        order: :id_desc
      }

      bans = Ban.search(params)

      assert_equal(1, bans.length)
      assert_equal(ban.id, bans.first.id)
    end

    context "by user id" do
      setup do
        @admin = FactoryGirl.create(:admin_user)
        CurrentUser.user = @admin
        CurrentUser.ip_addr = "127.0.0.1"
        @user = FactoryGirl.create(:user)
      end

      teardown do
        CurrentUser.user = nil
        CurrentUser.ip_addr = nil
      end

      context "when only expired bans exist" do
        setup do
          @ban = FactoryGirl.create(:ban, :user => @user, :banner => @admin, :duration => -1)
        end

        should "not return expired bans" do
          assert(!Ban.is_banned?(@user))
        end
      end

      context "when active bans still exist" do
        setup do
          @ban = FactoryGirl.create(:ban, :user => @user, :banner => @admin, :duration => 1)
        end

        should "return active bans" do
          assert(Ban.is_banned?(@user))
        end
      end
    end
  end
end
