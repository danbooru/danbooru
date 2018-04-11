require 'test_helper'

class UserNameChangeRequestTest < ActiveSupport::TestCase
  context "in all cases" do
    setup do
      @admin = FactoryBot.create(:admin_user)
      @requester = FactoryBot.create(:user)
      CurrentUser.user = @requester
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "approving a request" do
      setup do
        @change_request = UserNameChangeRequest.create(
          :user_id => @requester.id,
          :original_name => @requester.name,
          :status => "pending",
          :desired_name => "abc"
        )
        CurrentUser.user = @admin
      end
      
      should "create a dmail" do
        assert_difference("Dmail.count", 2) do
          @change_request.approve!
        end
      end
      
      should "change the user's name" do
        @change_request.approve!
        @requester.reload
        assert_equal("abc", @requester.name)
      end
      
      should "clear the user name cache" do
        @change_request.approve!
        assert_equal("abc", Cache.get("uin:#{@requester.id}"))
      end
      
      should "create feedback" do
        assert_difference("UserFeedback.count", 1) do
          @change_request.approve!
        end
      end
      
      should "create mod action" do
        assert_difference("ModAction.count", 1) do
          @change_request.approve!
        end
      end
    end
    
    context "rejecting a request" do
      setup do
        @change_request = UserNameChangeRequest.create(
          :user_id => @requester.id,
          :original_name => @requester.name,
          :status => "pending",
          :desired_name => "abc"
        )
        CurrentUser.user = @admin
      end
      
      should "create a dmail" do
        assert_difference("Dmail.count", 1) do
          @change_request.reject!("msg")
        end
      end
      
      should "preserve the username" do
        @change_request.reject!("msg")
        @requester.reload
        assert_not_equal("abc", @requester.name)
      end
    end
    
    context "creating a new request" do
      should "not validate if the desired name already exists" do
        assert_difference("UserNameChangeRequest.count", 0) do
          req = UserNameChangeRequest.create(
            :user_id => @requester.id,
            :original_name => @requester.name,
            :status => "pending",
            :desired_name => @requester.name
          )
          assert_equal(["Desired name already exists"], req.errors.full_messages)
        end
      end

      should "not convert the desired name to lower case" do
        uncr = FactoryBot.create(:user_name_change_request, user: @requester, original_name: "provence.", desired_name: "Provence")
        CurrentUser.scoped(@admin) { uncr.approve! }

        assert_equal("Provence", @requester.name)
      end
    end
  end
end
