# frozen_string_literal: true

class UserUpgradesController < ApplicationController
  respond_to :js, :html, :json, :xml

  def create
    @user_upgrade = authorize UserUpgrade.create(recipient: recipient, purchaser: CurrentUser.user, status: "pending", upgrade_type: params[:upgrade_type], payment_processor: params[:payment_processor])
    @country = params[:country] || "US"
    @allow_promotion_codes = params[:promo].to_s.truthy?
    @checkout = @user_upgrade.create_checkout!(country: @country, allow_promotion_codes: @allow_promotion_codes)

    respond_with(@user_upgrade)
  end

  def new
    @user_upgrade = authorize UserUpgrade.new(recipient: recipient, purchaser: CurrentUser.user)
    @recipient = @user_upgrade.recipient

    respond_with(@user_upgrade)
  end

  def index
    @user_upgrades = authorize UserUpgrade.visible(CurrentUser.user).paginated_search(params, count_pages: true)
    @user_upgrades = @user_upgrades.includes(:recipient, :purchaser) if request.format.html?

    respond_with(@user_upgrades)
  end

  def show
    @user_upgrade = authorize UserUpgrade.find(params[:id])
    respond_with(@user_upgrade)
  end

  def refund
    @user_upgrade = authorize UserUpgrade.find(params[:id])
    @user_upgrade.refund!

    respond_with(@user_upgrade, notice: "Upgrade refunded")
  end

  def receipt
    @user_upgrade = authorize UserUpgrade.find(params[:id])
    redirect_to @user_upgrade.receipt_url, allow_other_host: true
  end

  def payment
    @user_upgrade = authorize UserUpgrade.find(params[:id])
    redirect_to @user_upgrade.payment_url, allow_other_host: true
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
