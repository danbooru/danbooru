require "test_helper"

module Maintenance
  module User
    class LoginRemindersControllerTest < ActionDispatch::IntegrationTest
      context "A login reminder controller" do
        setup do
          @user = create(:user)
          @blank_email_user = create(:user, :email => "")
          ActionMailer::Base.delivery_method = :test
          ActionMailer::Base.deliveries.clear
        end

        should "render the new page" do
          get new_maintenance_user_login_reminder_path
          assert_response :success
        end

        should "deliver an email with the login to the user" do
          post maintenance_user_login_reminder_path, params: {:user => {:email => @user.email}}
          assert_equal(1, ActionMailer::Base.deliveries.size)
        end

        context "for a user with a blank email" do
          should "fail" do
            post maintenance_user_login_reminder_path, params: {:user => {:email => ""}}
            @blank_email_user.reload
            assert_equal(@blank_email_user.created_at.to_i, @blank_email_user.updated_at.to_i)
            assert_equal(0, ActionMailer::Base.deliveries.size)
          end
        end
      end
    end
  end
end
