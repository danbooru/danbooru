class SessionsController < ApplicationController
  respond_to :html, :json
  skip_forgery_protection only: :create, if: -> { !request.format.html? }

  def new
    @user = User.new
  end

  def create
    name, password, url = params.fetch(:session, params).slice(:name, :password, :url).values
    user = SessionLoader.new(request).login(name, password)

    if user
      url = posts_path unless url&.start_with?("/")
      respond_with(user, location: url, methods: [:api_token])
    else
      flash.now[:notice] = "Password was incorrect"
      raise SessionLoader::AuthenticationFailure
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to(posts_path, :notice => "You are now logged out")
  end

  def sign_out
    destroy
  end
end
