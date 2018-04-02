require "test_helper"

module Maintenance
  module User
    class DeletionsControllerTest < ActionDispatch::IntegrationTest
      context "in all cases" do
        setup do
          @user = create(:user)
        end

        context "#show" do
          should "render" do
            get_auth maintenance_user_deletion_path, @user
            assert_response :success
          end
        end

        context "#destroy" do
          should "render" do
            delete_auth maintenance_user_deletion_path, @user, params: {:password => "password"}
            assert_redirected_to(posts_path)
          end
        end
      end
    end
  end
end