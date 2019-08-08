class SessionsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    session_creator = SessionCreator.new(session, cookies, params[:name], params[:password], request.remote_ip, params[:remember], request.ssl?)

    if session_creator.authenticate
      url = params[:url] if params[:url] && params[:url].start_with?("/")
      redirect_to(url || posts_path, :notice => "You are now logged in")
    else
      redirect_to(new_session_path, :notice => "Password was incorrect")
    end
  end

  def destroy
    session.delete(:user_id)
    cookies.delete(:user_name)
    cookies.delete(:password_hash)
    redirect_to(posts_path, :notice => "You are now logged out")
  end

  def sign_out
    destroy()
  end
end
