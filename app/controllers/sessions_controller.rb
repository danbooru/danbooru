class SessionsController < ApplicationController
  def new
    @user = User.new
  end
  
  def create
    if User.authenticate(params[:name], params[:password])
      @user = User.find_by_name(params[:name])
      @user.update_column(:last_logged_in_at, Time.now)
      session[:user_id] = @user.id
      redirect_to(params[:url] || session[:previous_uri] || posts_path, :notice => "You are now logged in.")
    else
      redirect_to(new_session_path, :notice => "Password was incorrect.")
    end
  end
  
  def destroy
    session.delete(:user_id)
    redirect_to(posts_path, :notice => "You are now logged out.")
  end
end
