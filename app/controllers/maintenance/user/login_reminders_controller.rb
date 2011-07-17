module Maintenance
  module User
    class LoginRemindersController < ApplicationController
      def new
      end
      
      def create
        @user = ::User.with_email(params[:user][:email]).first
        if @user
          LoginReminderMailer.notice(@user).deliver
          flash[:notice] = "Email sent"
        else
          flash[:notice] = "Email address not found"
        end
        
        redirect_to new_maintenance_user_login_reminder_path
      end
    end
  end
end
