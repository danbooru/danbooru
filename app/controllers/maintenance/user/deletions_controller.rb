module Maintenance
  module User
    class DeletionsController < ApplicationController
      def show
      end

      def destroy
        deletion = UserDeletion.new(CurrentUser.user, params[:password])
        deletion.delete!
        session.delete(:user_id)
        cookies.delete(:password_hash)
        cookies.delete(:user_name)
        redirect_to(posts_path, :notice => "You are now logged out")
      end
    end
  end
end
