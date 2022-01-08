# frozen_string_literal: true

class SessionsController < ApplicationController
  respond_to :html, :json
  skip_forgery_protection only: :create, if: -> { !request.format.html? }

  rate_limit :create, rate: 1.0/1.minute, burst: 10

  def new
    @user = User.new
  end

  def confirm_password
  end

  def create
    name, password, url = params.fetch(:session, params).slice(:name, :password, :url).values
    user = SessionLoader.new(request).login(name, password)
    url ||= posts_path

    if user
      respond_with(user, location: url)
    else
      flash.now[:notice] = "Password was incorrect"
      raise SessionLoader::AuthenticationFailure
    end
  end

  def destroy
    SessionLoader.new(request).logout
    redirect_to(posts_path, :notice => "You are now logged out")
  end

  def sign_out
    destroy
  end
end
