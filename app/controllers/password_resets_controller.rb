class PasswordResetsController < ApplicationController
  respond_to :html, :xml, :json

  def create
    @user = User.find_by_name(params.dig(:user, :name))
    UserMailer.password_reset(@user).deliver_later

    flash[:notice] = "Password reset email sent. Check your email"
    respond_with(@user, location: new_session_path)
  end

  def show
  end
end
