module M
  class SessionsController < ApplicationController
    layout "mobile"

    def new
      @user = User.new
    end
  
    def create
      session_creator = SessionCreator.new(session, cookies, params[:name], params[:password], params[:remember])
    
      if session_creator.authenticate
        redirect_to(params[:url] || session[:previous_uri] || m_posts_path)
      else
        redirect_to(new_m_session_path, :notice => "Password was incorrect.")
      end
    end
  
    def destroy
      session.delete(:user_id)
      cookies.delete(:cookie_password_hash)
      cookies.delete(:user_name)
      redirect_to(m_posts_path, :notice => "You are now logged out.")
    end
  end
end
