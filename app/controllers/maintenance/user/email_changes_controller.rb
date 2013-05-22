module Maintenance
  module User
    class EmailChangesController < ApplicationController
      def new
      end

      def create
        email_change = UserEmailChange.new(CurrentUser.user, params[:email_change][:email], params[:email_change][:password])
        if email_change.process
          redirect_to(edit_user_path(CurrentUser.user.id), :notice => "Email was updated")
        else
          flash[:notice] = "Password was incorrect"
          render :action => "new"
        end
      end
    end
  end
end
