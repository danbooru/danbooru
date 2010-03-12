class UsersController < ApplicationController
  respond_to :html, :xml, :json

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
    @user = User.new(params[:user])
    flash[:notice] = "You have succesfully created a new account." if @user.save
    respond_with(@user)
  end
  
  def update
  end
  
  def destroy
  end
end
