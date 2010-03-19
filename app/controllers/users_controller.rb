class UsersController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :member_only, :only => [:edit, :show, :update, :destroy, :create]

  def new
    @user = User.new
  end
  
  def edit
    @user = User.find(params[:id])
    unless @current_user.is_admin?
      @user = @current_user
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
      flash[:notice] = "You have succesfully created a new account."
      session[:user_id] = @user.id
    end
    respond_with(@user)
  end
  
  def update
  end
  
  def destroy
  end
end
