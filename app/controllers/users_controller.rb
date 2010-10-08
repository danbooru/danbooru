class UsersController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :member_only, :only => [:edit, :show, :update, :destroy]

  def new
    @user = User.new
  end
  
  def edit
    @user = User.find(params[:id])
    unless CurrentUser.user.is_admin?
      @user = CurrentUser.user
    end
  end
  
  def index
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def create
    @user = User.new(params[:user].merge(:ip_addr => request.remote_ip))
    if @user.save
      flash[:notice] = "You have succesfully created a new account"
      session[:user_id] = @user.id
      redirect_to user_path(@user)
    else
      flash[:notice] = "There were errors"
      render :action => "new"
    end
  end
  
  def update
  end
  
  def destroy
  end
end
