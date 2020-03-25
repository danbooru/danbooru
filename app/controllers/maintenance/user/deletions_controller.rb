module Maintenance
  module User
    class DeletionsController < ApplicationController
      def show
      end

      def destroy
        deletion = UserDeletion.new(CurrentUser.user, params[:password])
        deletion.delete!
        session.delete(:user_id)
        redirect_to(posts_path, :notice => "You are now logged out")
      end
    end
  end
end
