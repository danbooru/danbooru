module Admin
  class UsersController < ApplicationController
    def edit
      @user = authorize User.find(params[:id]), :promote?
    end

    def update
      @user = authorize User.find(params[:id]), :promote?
      @user.promote_to!(params[:user][:level], params[:user])
      redirect_to edit_admin_user_path(@user), :notice => "User updated"
    end
  end
end
