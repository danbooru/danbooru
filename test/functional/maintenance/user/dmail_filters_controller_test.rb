require "test_helper"

module Maintenance
  module User
    class DmailFiltersControllerTest < ActionDispatch::IntegrationTest
      context "The dmail filters controller" do
        setup do
          @user1 = create(:user)
          @user2 = create(:user)
        end

        context "update action" do
          setup do
            as(@user1) do
              @dmail = create(:dmail, owner: @user1)
            end
          end

          should "not allow a user to create a filter belonging to another user" do
            params = {
              :dmail_id => @dmail.id,
              :dmail_filter => {
                :words => "owned",
                :user_id => @user2.id
              }
            }

            put_auth maintenance_user_dmail_filter_path, @user1, params: params
            assert_not_equal("owned", @user2.reload.dmail_filter.try(&:words))
          end
        end
      end
    end
  end
end
