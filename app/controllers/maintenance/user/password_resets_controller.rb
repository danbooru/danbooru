module Maintenance
  module User
    class PasswordResetsController < ApplicationController
      def new
        @nonce = UserPasswordResetNonce.new
      end

      def create
        @nonce = UserPasswordResetNonce.create(nonce_params)
        if @nonce.errors.any?
          redirect_to new_maintenance_user_password_reset_path, :notice => @nonce.errors.full_messages.join("; ")
        else
          redirect_to new_maintenance_user_password_reset_path, :notice => "Email request sent"
        end
      end

      def edit
        @nonce = UserPasswordResetNonce.where(:email => params[:email], :key => params[:key]).first
      end

      def update
        @nonce = UserPasswordResetNonce.where(:email => params[:email], :key => params[:key]).first

        if @nonce
          @nonce.reset_user!
          @nonce.destroy
          redirect_to new_maintenance_user_password_reset_path, :notice => "Password reset; email delivered with new password"
        else
          redirect_to new_maintenance_user_password_reset_path, :notice => "Invalid key"
        end
      end

      def nonce_params
        params.require(:nonce).permit([:email])
      end
    end
  end
end
