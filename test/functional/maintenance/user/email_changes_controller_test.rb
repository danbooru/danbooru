require "test_helper"

module Maintenance
  module User
    class EmailChangesControllerTest < ActionDispatch::IntegrationTest
      context "in all cases" do
        setup do
          @user = create(:user, :email => "bob@ogres.net")
        end

        context "#new" do
          should "render" do
            get_auth new_maintenance_user_email_change_path, @user
            assert_response :success
          end
        end

        context "#create" do
          context "with the correct password" do
            should "work" do
              post_auth maintenance_user_email_change_path, @user, params: {:email_change => {:password => "password", :email => "abc@ogres.net"}}
              assert_redirected_to(edit_user_path(@user))
              @user.reload
              assert_equal("abc@ogres.net", @user.email)
            end
          end

          context "with the incorrect password" do
            should "not work" do
              post_auth maintenance_user_email_change_path, @user, params: {:email_change => {:password => "passwordx", :email => "abc@ogres.net"}}
              @user.reload
              assert_equal("bob@ogres.net", @user.email)
            end
          end
        end
      end
    end
  end
end