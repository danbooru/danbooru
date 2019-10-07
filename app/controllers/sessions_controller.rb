class SessionsController < ApplicationController
  respond_to :html, :json
  skip_forgery_protection only: :create, if: -> { request.format.json? }

  def new
    @user = User.new
  end

  def create
    session_creator = SessionCreator.new(session, cookies, params[:name], params[:password], request.remote_ip, params[:remember], request.ssl?)

    if session_creator.authenticate
      url = params[:url] if params[:url] && params[:url].start_with?("/")
      url = posts_path if url.nil?
      respond_with(session_creator.user, location: url, methods: [:api_token])
    else
      respond_with("password was incorrect", location: new_session_path) do |fmt|
        fmt.json do
          render json: { error: true, message: "password was incorrect"}.to_json, status: 401
        end

        fmt.html do
          flash[:notice] = "Password was incorrect"
        end
      end
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
