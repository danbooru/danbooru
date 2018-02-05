require "test_helper"

module Maintenance
  module User
    class DmailFiltersControllerTest < ActionController::TestCase
      context "The dmail filters controller" do
        setup do
          @user1 = FactoryGirl.create(:user)
          @user2 = FactoryGirl.create(:user)
          CurrentUser.user = @user1
          CurrentUser.ip_addr = "127.0.0.1"
        end

        teardown do
          CurrentUser.user = nil
          CurrentUser.ip_addr = nil
        end

        context "update action" do
          should "not allow a user to create a filter belonging to another user" do
            @dmail = FactoryGirl.create(:dmail, :owner => @user1)

            params = {
              :dmail_id => @dmail.id,
              :dmail_filter => {
                :words => "owned",
                :user_id => @user2.id
              }
            }

            post :update, params, { :user_id => @user1.id }

            assert_not_equal("owned", @user2.reload.dmail_filter.try(&:words))
          end
        end
      end
    end
  end
end
