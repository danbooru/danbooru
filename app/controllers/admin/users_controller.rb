module Admin
  class UsersController < ApplicationController
    before_filter :admin_only
    
    def edit
      @user = User.find(params[:id])
    end
    
    def update
      @user = User.find(params[:id])
      @user.level = params[:user][:level]
      @user.save
      redirect_to admin_user_path(@user, :notice => "User updated")
    end
  end
end
