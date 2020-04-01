class PasswordResetsController < ApplicationController
  respond_to :html, :xml, :json

  def create
    @user = User.find_by_name(params.dig(:user, :name))

    if @user.blank?
      flash[:notice] = "That account does not exist"
      redirect_to password_reset_path
    elsif @user.can_receive_email?(require_verification: false)
      UserMailer.password_reset(@user).deliver_later
      flash[:notice] = "Password reset email sent. Check your email"
      respond_with(@user, location: new_session_path)
    else
      flash[:notice] = "Password not reset. This account does not have a valid, verified email address"
      respond_with(@user)
    end
  end

  def show
  end
end
