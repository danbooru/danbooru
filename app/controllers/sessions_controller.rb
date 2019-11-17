class SessionsController < ApplicationController
  respond_to :html, :json
  skip_forgery_protection only: :create, if: -> { !request.format.html? }

  def new
    @user = User.new
  end

  def create
    session_creator = SessionCreator.new(session, params[:name], params[:password], request.remote_ip)

    if session_creator.authenticate
      url = params[:url] if params[:url] && params[:url].start_with?("/")
      url = posts_path if url.nil?
      respond_with(session_creator.user, location: url, methods: [:api_token])
    else
      flash.now[:notice] = "Password was incorrect"
      raise SessionLoader::AuthenticationFailure
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
