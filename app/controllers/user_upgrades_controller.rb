class UserUpgradesController < ApplicationController
  respond_to :js, :html

  def create
    @user_upgrade = authorize UserUpgrade.create(recipient: recipient, purchaser: CurrentUser.user, status: "pending", upgrade_type: params[:upgrade_type])
    @checkout = @user_upgrade.create_checkout!

    respond_with(@user_upgrade)
  end

  def new
    @user_upgrade = authorize UserUpgrade.new(recipient: recipient, purchaser: CurrentUser.user)
    @recipient = @user_upgrade.recipient

    respond_with(@user_upgrade)
  end

  def show
    @user_upgrade = authorize UserUpgrade.find(params[:id])
    respond_with(@user_upgrade)
  end

  private

  def recipient
    if params[:user_id]
      User.find(params[:user_id])
    else
      CurrentUser.user
    end
  end
end
