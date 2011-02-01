require 'test_helper'

class UserMaintenanceControllerTest < ActionController::TestCase
  context "The user maintenance controller" do
    setup do
      @user = Factory.create(:user)
      @blank_email_user = Factory.create(:user, :email => "")
      CurrentUser.user = nil
      CurrentUser.ip_addr = "127.0.0.1"
      ActionMailer::Base.deliveries.clear
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "login_reminder action" do
      should "deliver an email with the login to the user" do
        post :login_reminder, {:user => {:email => @user.email}}
        assert_equal(flash[:notice], "Email sent")
        assert_equal(1, ActionMailer::Base.deliveries.size)
      end
      
      context "for a user with a blank email" do
        should "fail" do
          post :login_reminder, {:user => {:email => ""}}
          assert_equal("No matching user record found", flash[:notice])
          @blank_email_user.reload
          assert_equal(@blank_email_user.created_at, @blank_email_user.updated_at)
          assert_equal(0, ActionMailer::Base.deliveries.size)
        end
      end
    end
    
    context "reset_password action" do
      setup do
        @old_password = @user.password_hash
      end
      
      should "reset the user's password and deliver an email to the user" do
        post :reset_password, {:user => {:email => @user.email, :name => @user.name}}
        assert_equal("Email sent", flash[:notice])
        @user.reload
        assert_not_equal(@old_password, @user.password)
        assert_equal(1, ActionMailer::Base.deliveries.size)
      end
      
      context "for a user with a blank email" do
        should "fail" do
          post :reset_password, {:user => {:email => "", :name => @blank_email_user.name}}
          assert_equal("No matching user record found", flash[:notice])
          @blank_email_user.reload
          assert_equal(@blank_email_user.created_at, @blank_email_user.updated_at)
          assert_equal(0, ActionMailer::Base.deliveries.size)
        end
      end
    end
  end
end
