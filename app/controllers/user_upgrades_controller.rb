class UserUpgradesController < ApplicationController
  helper_method :user
  respond_to :js, :html

  def create
    @user_upgrade = UserUpgrade.new(recipient: user, purchaser: CurrentUser.user, level: params[:level].to_i)
    @checkout = @user_upgrade.create_checkout

    respond_with(@user_upgrade)
  end

  def new
  end

  def show
    authorize User, :upgrade?
  end

  def user
    if params[:user_id]
      User.find(params[:user_id])
    else
      CurrentUser.user
    end
  end
end
