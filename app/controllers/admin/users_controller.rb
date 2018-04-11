module Admin
  class UsersController < ApplicationController
    before_action :moderator_only

    def edit
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])
      promotion = UserPromotion.new(@user, CurrentUser.user, params[:user][:level], params[:user])
      promotion.promote!
      redirect_to edit_admin_user_path(@user), :notice => "User updated"
    end
  end
end
