class UserUpgradesController < ApplicationController
  helper_method :user
  respond_to :js, :html

  def create
    @user_upgrade = authorize UserUpgrade.create(recipient: user, purchaser: CurrentUser.user, status: "pending", upgrade_type: params[:upgrade_type])
    @checkout = @user_upgrade.create_checkout!

    respond_with(@user_upgrade)
  end

  def new
  end

  def show
    @user_upgrade = authorize UserUpgrade.find(params[:id])
    respond_with(@user_upgrade)
  end

  def user
    if params[:user_id]
      User.find(params[:user_id])
    else
      CurrentUser.user
    end
  end
end
