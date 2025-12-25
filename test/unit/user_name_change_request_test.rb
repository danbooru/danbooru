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
