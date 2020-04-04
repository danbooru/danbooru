module Maintenance
  module User
    class DeletionsController < ApplicationController
      respond_to :html, :json, :xml

      def show
      end

      def destroy
        deletion = UserDeletion.new(CurrentUser.user, params.dig(:user, :password))
        deletion.delete!

        if deletion.errors.none?
          session.delete(:user_id)
          flash[:notice] = "Your account has been deactivated"
          respond_with(deletion, location: posts_path)
        else
          flash[:notice] = deletion.errors.full_messages.join("; ")
          redirect_to maintenance_user_deletion_path
        end
      end
    end
  end
end
