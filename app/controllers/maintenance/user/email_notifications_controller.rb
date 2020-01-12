module Maintenance
  module User
    class EmailNotificationsController < ApplicationController
      class VerificationError < StandardError; end

      before_action :validate_sig, :only => [:destroy]
      rescue_from VerificationError, :with => :render_403

      def show
      end

      def destroy
        @user = User.find(params[:user_id])
        @user.receive_email_notifications = false
        @user.save
      end

      private

      def render_403
        render plain: "", :status => 403
      end

      def validate_sig
        verifier = ActiveSupport::MessageVerifier.new(Danbooru.config.email_key, digest: "SHA256", serializer: JSON)
        calculated_sig = verifier.generate(params[:user_id].to_s)
        if calculated_sig != params[:sig]
          raise VerificationError.new
        end
      end
    end
  end
end
