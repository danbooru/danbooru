# frozen_string_literal: true

module Maintenance
  module User
    class EmailNotificationsController < ApplicationController
      class VerificationError < StandardError; end

      respond_to :html, :json, :xml

      before_action :validate_sig, only: [:create, :destroy]
      skip_forgery_protection only: [:create, :destroy]
      rescue_with VerificationError, status: 403

      def show
      end

      def destroy
        @user = ::User.find(params[:user_id])
        @user.update!(receive_email_notifications: false)

        # https://www.rfc-editor.org/rfc/rfc8058#section-3.1
        #
        # A mail receiver can do a one-click unsubscription by performing an HTTPS POST to the HTTPS URI in the
        # List-Unsubscribe header. It sends the key/value pair in the List-Unsubscribe-Post header as the request body.
        # The List-Unsubscribe-Post header MUST contain the single key/value pair "List-Unsubscribe=One-Click".
        # The mail sender MUST NOT return an HTTPS redirect
        if params["List-Unsubscribe"] == "One-Click"
          head 200
        else
          respond_with(@user)
        end
      end
      alias_method :create, :destroy

      private

      def validate_sig
        verifier = ActiveSupport::MessageVerifier.new(Danbooru.config.email_key, digest: "SHA256", serializer: JSON)
        calculated_sig = verifier.generate(params[:user_id].to_s)
        if calculated_sig != params[:sig]
          raise VerificationError, "Invalid signature"
        end
      end
    end
  end
end
