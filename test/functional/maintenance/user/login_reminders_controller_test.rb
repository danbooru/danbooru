require "test_helper"

module Maintenance
  module User
    class LoginRemindersControllerTest < ActionController::TestCase
      context "A login reminder controller" do
        setup do
          @user = FactoryGirl.create(:user)
          @blank_email_user = FactoryGirl.create(:user, :email => "")
          CurrentUser.user = nil
          CurrentUser.ip_addr = "127.0.0.1"
          ActionMailer::Base.delivery_method = :test
          ActionMailer::Base.deliveries.clear
        end

        teardown do
          CurrentUser.user = nil
          CurrentUser.ip_addr = nil
        end

        should "render the new page" do
          get :new
          assert_response :success
        end

        should "deliver an email with the login to the user" do
          post :create, {:user => {:email => @user.email}}
          assert_equal(flash[:notice], "Email sent")
          assert_equal(1, ActionMailer::Base.deliveries.size)
        end

        context "for a user with a blank email" do
          should "fail" do
            post :create, {:user => {:email => ""}}
            assert_equal("Email address not found", flash[:notice])
            @blank_email_user.reload
            assert_equal(@blank_email_user.created_at.to_i, @blank_email_user.updated_at.to_i)
            assert_equal(0, ActionMailer::Base.deliveries.size)
          end
        end
      end
    end
  end
end
