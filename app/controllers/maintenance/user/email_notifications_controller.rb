# frozen_string_literal: true

module Maintenance
  module User
    class EmailNotificationsController < ApplicationController
      class VerificationError < StandardError; end

      before_action :validate_sig, :only => [:destroy]
      rescue_from VerificationError, with: :render_verification_error

      def show
      end

      def destroy
        @user = User.find(params[:user_id])
        @user.receive_email_notifications = false
        @user.save
      end

      private

      def render_verification_error
        render plain: "", status: 403
      end

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
