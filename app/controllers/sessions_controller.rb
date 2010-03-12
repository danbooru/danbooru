class SessionsController < ApplicationController
  before_filter :member_only, :only => [:destroy]
  
  def new
    @user = User.new
  end
  
  def create
    if User.authenticate(params[:name], params[:password])
      @user = User.find_by_name(params[:name])
      session[:user_id] = @user.id
      redirect_to(params[:url] || posts_path, :notice => "You have logged in")
    else
      render :action => "edit", :flash => "Password was incorrect"
    end
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to(posts_path, :notice => "You have logged out")
  end
end
