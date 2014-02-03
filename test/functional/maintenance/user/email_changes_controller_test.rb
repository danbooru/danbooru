require "test_helper"

module Maintenance
  module User
    class EmailChangesControllerTest < ActionController::TestCase
      context "in all cases" do
        setup do
          @user = FactoryGirl.create(:user, :email => "bob@ogres.net")
          CurrentUser.user = @user
          CurrentUser.ip_addr = "127.0.0.1"
        end

        context "#new" do
          should "render" do
            get :new, {}, {:user_id => @user.id}
            assert_response :success
          end
        end

        context "#create" do
          context "with the correct password" do
            should "work" do
              post :create, {:email_change => {:password => "password", :email => "abc@ogres.net"}}, {:user_id => @user.id}
              assert_redirected_to(edit_user_path(@user))
              @user.reload
              assert_equal("abc@ogres.net", @user.email)
            end
          end

          context "with the incorrect password" do
            should "not work" do
              post :create, {:email_change => {:password => "passwordx", :email => "abc@ogres.net"}}, {:user_id => @user.id}
              @user.reload
              assert_equal("bob@ogres.net", @user.email)
            end
          end
        end
      end
    end
  end
end