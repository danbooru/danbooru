require 'test_helper'

module Maintenance
  module User
    class ApiKeysControllerTest < ActionController::TestCase
      def params(password = "password")
        { :user_id => @user.id, :user => { :password => password } }
      end

      context "An api keys controller" do
        setup do
          @user = FactoryGirl.create(:gold_user, :password => "password")
          CurrentUser.user = @user
          CurrentUser.ip_addr = "127.0.0.1"
          ApiKey.generate!(@user)
        end

        teardown do
          @user.api_key.destroy if @user.api_key
        end

        context "#show" do
          should "render" do
            get :show, {:user_id => @user.id}, {:user_id => @user.id}
            assert_response :success
          end
        end

        context "#view" do
          context "with an incorrect password" do
            should "redirect" do
              post :view, params("hunter2"), { :user_id => @user.id }
              assert_redirected_to(user_api_key_path(@user))
            end
          end

          context "with a correct password" do
            should "succeed" do
              post :view, params, { :user_id => @user.id }
              assert_response :success
            end

            should "generate an API key if the user didn't already have one" do
              @user.api_key.destroy

              assert_difference("ApiKey.count", 1) do
                post :view, params, { :user_id => @user.id }
              end

              assert_not_nil(@user.reload.api_key)
            end

            should "not generate another API key if the user already has one" do
              assert_difference("ApiKey.count", 0) do
                post :view, params, { :user_id => @user.id }
              end
            end
          end
        end

        context "#update" do
          should "regenerate the API key" do
            old_key = @user.api_key
            post :update, params, { :user_id => @user.id }
            assert_not_equal(old_key.key, @user.reload.api_key.key)
          end
        end

        context "#destroy" do
          should "delete the API key" do
            post :destroy, params, { :user_id => @user.id }
            assert_nil(@user.reload.api_key)
          end
        end
      end
    end
  end
end
