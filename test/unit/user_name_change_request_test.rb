require 'test_helper'

class UserNameChangeRequestTest < ActiveSupport::TestCase
  context "in all cases" do
    setup do
      @admin = FactoryGirl.create(:admin_user)
      @requester = FactoryGirl.create(:user)
      CurrentUser.user = @requester
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
        assert_difference("Dmail.count", 2) do
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
      should "send dmails to the admin" do
        assert_difference("Dmail.count", 2) do
          UserNameChangeRequest.create(
            :user_id => @requester.id,
            :original_name => @requester.name,
            :status => "pending",
            :desired_name => "abc"
          )
        end
      end
      
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
    end
  end
end
