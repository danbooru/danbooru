module Maintenance
  module User
    class ApiKeysController < ApplicationController
      before_filter :member_only
      before_filter :check_privilege
      before_filter :authenticate!, :except => [:show]
      rescue_from ::SessionLoader::AuthenticationFailure, :with => :authentication_failed
      respond_to :html, :json, :xml

      def view
        respond_with(CurrentUser.user, @api_key)
      end

      def update
        @api_key.regenerate!
        respond_with(CurrentUser.user, @api_key) { |format| format.js }
      end

      def destroy
        @api_key.destroy
        respond_with(CurrentUser.user, @api_key, location: CurrentUser.user)
      end

      protected

      def check_privilege
        raise ::User::PrivilegeError unless params[:user_id].to_i == CurrentUser.id
      end

      def authenticate!
        if ::User.authenticate(CurrentUser.user.name, params[:user][:password]) == CurrentUser.user
          @api_key = CurrentUser.user.api_key || ApiKey.generate!(CurrentUser.user)
          @password = params[:user][:password]
        else
          raise ::SessionLoader::AuthenticationFailure
        end
      end

      def authentication_failed
        redirect_to(user_api_key_path(CurrentUser.user), :notice => "Password was incorrect.")
      end
    end
  end
end
