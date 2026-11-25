require "test_helper"

class UserNameChangeRequestTest < ActiveSupport::TestCase
  context "For user name changes" do
    setup do
      @admin = create(:admin_user)
      @requester = create(:user, name: "provence")
      @restricted_requester = create(:restricted_user, name: "provence_sock")
    end

    context "creating a new request" do
      should "change the user's name" do
        @change_request = create(:user_name_change_request, user_id: @requester.id, original_name: @requester.name, desired_name: "abc")
        assert_equal("abc", @requester.reload.name)
      end

      should "not validate if the desired name already exists" do
        assert_difference("UserNameChangeRequest.count", 0) do
          user = create(:user)
          req = build(:user_name_change_request, user: user, original_name: user.name, desired_name: @requester.name)
          req.valid?

          assert_equal(["Desired name already taken"], req.errors.full_messages)
        end
      end

      should "not allow taking a name another user recently changed away from" do
        create(:user_name_change_request, user: @requester, original_name: "provence", desired_name: "abc")

        user = create(:user)
        req = build(:user_name_change_request, user: user, original_name: user.name, desired_name: "Provence")

        assert_equal(false, req.valid?)
        assert_equal(["Desired name was recently used by another user"], req.errors.full_messages)
      end

      should "allow taking a name another user changed away from more than a year ago" do
        create(:user_name_change_request, user: @requester, original_name: "provence", desired_name: "abc")

        travel_to(1.year.from_now + 1.day) do
          user = create(:user)
          req = build(:user_name_change_request, user: user, original_name: user.name, desired_name: "provence")

          assert_equal(true, req.valid?)
        end
      end

      should "allow a moderator to give a stolen name back to its original owner" do
        alice = create(:user, name: "alice")
        create(:user_name_change_request, user: alice, original_name: "alice", desired_name: "alice2")
        bob = create(:user, name: "bob")
        bob.update_columns(name: "alice") # rubocop:disable Rails/SkipsModelValidations -- name stolen before old names were reserved

        create(:user_name_change_request, user: bob, updater: @admin, original_name: "alice", desired_name: "bob")
        create(:user_name_change_request, user: alice.reload, updater: @admin, original_name: "alice2", desired_name: "alice")

        assert_equal("alice", alice.reload.name)
      end

      should "allow the user to change back to their own old name" do
        create(:user_name_change_request, user: @requester, original_name: "provence", desired_name: "abc")

        travel_to(2.weeks.from_now) do
          create(:user_name_change_request, user: @requester.reload, original_name: "abc", desired_name: "provence")
          assert_equal("provence", @requester.reload.name)
        end
      end

      should "not convert the desired name to lower case" do
        create(:user_name_change_request, user: @requester, original_name: "provence.", desired_name: "Provence")

        assert_equal("Provence", @requester.name)
      end

      should "allow the user to change the case of their name" do
        create(:user_name_change_request, user: @requester, original_name: "provence", desired_name: "Provence")

        assert_equal("Provence", @requester.name)
      end

      should "fail for restricted users" do
        req = build(:user_name_change_request, user: @restricted_requester, original_name: "provence_sock", desired_name: "provence_sock2")

        assert(req.valid?, false)
      end

      should "succeed for restricted users with an invalid name" do
        UserNameValidator.stubs(:RESERVED_NAMES).returns(["provence_sock"])
        req = build(:user_name_change_request, user: @restricted_requester, original_name: "provence_sock", desired_name: "provence_sock2")

        assert(req.valid?, true)
      end
    end
  end
end
