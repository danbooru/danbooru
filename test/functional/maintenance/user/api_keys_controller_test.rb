require 'test_helper'

module Maintenance
  module User
    class ApiKeysControllerTest < ActionDispatch::IntegrationTest
      context "An api keys controller" do
        setup do
          @user = create(:gold_user, :password => "password")
          ApiKey.generate!(@user)
        end

        context "#show" do
          should "render" do
            get_auth maintenance_user_api_key_path, @user, params: {user_id: @user.id}
            assert_response :success
          end
        end

        context "#view" do
          context "with a correct password" do
            should "succeed" do
              post_auth view_maintenance_user_api_key_path(user_id: @user.id), @user, params: {user: {password: "password"}}
              assert_response :success
            end

            should "not generate another API key if the user already has one" do
              assert_difference("ApiKey.count", 0) do
                post_auth view_maintenance_user_api_key_path(user_id: @user.id), @user, params: {user: {password: "password"}}
              end
            end
          end
        end

        context "#update" do
          should "regenerate the API key" do
            old_key = @user.api_key
            put_auth maintenance_user_api_key_path, @user, params: {user_id: @user.id, user: {password: "password"}}
            assert_not_equal(old_key.key, @user.reload.api_key.key)
          end
        end

        context "#destroy" do
          should "delete the API key" do
            delete_auth maintenance_user_api_key_path, @user, params: {user_id: @user.id, user: {password: "password"}}
            assert_nil(@user.reload.api_key)
          end
        end
      end
    end
  end
end
