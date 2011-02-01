class UserMaintenanceController < ApplicationController
  def login_reminder
    if request.post?
      @user = User.with_email(params[:user][:email]).first
      if @user
        UserMaintenanceMailer.login_reminder(@user).deliver
        flash[:notice] = "Email sent"
      else
        flash[:notice] = "No matching user record found"
      end
    end
  end
  
  def reset_password
    if request.post?
      @user = User.find_for_password_reset(params[:user][:name], params[:user][:email]).first
      if @user
        @user.reset_password_and_deliver_notice
        flash[:notice] = "Email sent"
      else
        flash[:notice] = "No matching user record found"
      end
    end
  end
end
