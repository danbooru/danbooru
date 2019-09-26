require 'test_helper'

class UserNameChangeRequestTest < ActiveSupport::TestCase
  context "in all cases" do
    setup do
      @admin = FactoryBot.create(:admin_user)
      @requester = FactoryBot.create(:user)
    end

    context "creating a new request" do
      should "change the user's name" do
        @change_request = create(:user_name_change_request, user_id: @requester.id, original_name: @requester.name, desired_name: "abc")
        assert_equal("abc", @requester.reload.name)
      end

      should "not validate if the desired name already exists" do
        assert_difference("UserNameChangeRequest.count", 0) do
          req = UserNameChangeRequest.create(
            :user_id => @requester.id,
            :original_name => @requester.name,
            :desired_name => @requester.name
          )
          assert_equal(["Desired name already exists"], req.errors.full_messages)
        end
      end

      should "not convert the desired name to lower case" do
        uncr = create(:user_name_change_request, user: @requester, original_name: "provence.", desired_name: "Provence")

        assert_equal("Provence", @requester.name)
      end
    end
  end
end
