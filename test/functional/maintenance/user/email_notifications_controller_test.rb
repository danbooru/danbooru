require "test_helper"

module Maintenance
  module User
    class EmailNotificationsControllerTest < ActionDispatch::IntegrationTest
      context "Email notifications" do
        setup do
          @user = create(:user, receive_email_notifications: true)
          @verifier = ActiveSupport::MessageVerifier.new(Danbooru.config.email_key, digest: "SHA256", serializer: JSON)
          @sig = @verifier.generate(@user.id.to_s)
        end

        context "#show" do
          should "render" do
            get_auth maintenance_user_email_notification_path(user_id: @user.id), @user
            assert_response :success
          end
        end

        context "#destroy" do
          should "disable email notifications" do
            delete maintenance_user_email_notification_path(user_id: @user.id, sig: @sig)

            assert_response :success
            assert_equal(false, @user.reload.receive_email_notifications)
          end

          should "disable email notifications from a one-click unsubscribe" do
            post maintenance_user_email_notification_path(user_id: @user.id, sig: @sig), params: { "List-Unsubscribe": "One-Click" }

            assert_response :success
            assert_equal(false, @user.reload.receive_email_notifications)
          end

          should "not disable email notifications when given an incorrect signature" do
            delete maintenance_user_email_notification_path(user_id: @user.id, sig: "foo")

            assert_response 403
            assert_equal(true, @user.reload.receive_email_notifications)
          end
        end
      end
    end
  end
end
