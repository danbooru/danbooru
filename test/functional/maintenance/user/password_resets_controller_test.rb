require "test_helper"

module Maintenance
  module User
    class PasswordResetsControllerTest < ActionController::TestCase
      context "A password resets controller" do
        setup do
          @user = FactoryGirl.create(:user, :email => "abc@com.net")
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
        
        context "create action" do
          context "given invalid parameters" do
            setup do
              post :create, {:nonce => {:email => ""}}
            end
            
            should "not create a new nonce" do
              assert_equal(0, UserPasswordResetNonce.count)
            end

            should "redirect to the new page" do
              assert_redirected_to new_maintenance_user_password_reset_path
            end

            should "not deliver an email" do
              assert_equal(0, ActionMailer::Base.deliveries.size)
            end
          end
          
          context "given valid parameters" do
            setup do
              post :create, {:nonce => {:email => @user.email}}
            end

            should "create a new nonce" do
              assert_equal(1, UserPasswordResetNonce.where(:email => @user.email).count)
            end
            
            should "redirect to the new page" do
              assert_redirected_to new_maintenance_user_password_reset_path
            end

            should "deliver an email to the supplied email address" do
              assert_equal(1, ActionMailer::Base.deliveries.size)
            end
          end
        end

        context "edit action" do
          context "with invalid parameters" do
            setup do
              get :edit, :email => "a@b.c"
            end

            should "succeed silently" do
              assert_response :success
            end
          end
          
          context "with valid parameters" do
            setup do
              @user = FactoryGirl.create(:user)
              @nonce = FactoryGirl.create(:user_password_reset_nonce, :email => @user.email)
              ActionMailer::Base.deliveries.clear
              get :edit, :email => @nonce.email, :key => @nonce.key
            end
            
            should "succeed" do
              assert_response :success
            end
          end
        end
        
        context "update action" do
          context "with invalid parameters" do
            setup do
              get :update
            end
            
            should "fail" do
              assert_redirected_to new_maintenance_user_password_reset_path
            end
          end
          
          context "with valid parameters" do
            setup do
              @user = FactoryGirl.create(:user)
              @nonce = FactoryGirl.create(:user_password_reset_nonce, :email => @user.email)
              ActionMailer::Base.deliveries.clear
              @old_password = @user.bcrypt_password_hash
              post :update, :email => @nonce.email, :key => @nonce.key
            end
            
            should "succeed" do
              assert_redirected_to new_maintenance_user_password_reset_path
            end
            
            should "send an email" do
              assert_equal(1, ActionMailer::Base.deliveries.size)
            end
            
            should "change the password" do
              @user.reload
              assert_not_equal(@old_password, @user.bcrypt_password_hash)
            end
            
            should "delete the nonce" do
              assert_equal(0, UserPasswordResetNonce.count)
            end
          end
        end
      end
    end
  end
end
