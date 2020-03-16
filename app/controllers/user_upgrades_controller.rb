class UserUpgradesController < ApplicationController
  helper_method :user
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    if params[:stripeToken]
      create_stripe
    end
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

  private

  def create_stripe
    @user = user

    if params[:desc] == "Upgrade to Gold"
      level = User::Levels::GOLD
      cost = UserUpgrade.gold_price
    elsif params[:desc] == "Upgrade to Platinum"
      level = User::Levels::PLATINUM
      cost = UserUpgrade.platinum_price
    elsif params[:desc] == "Upgrade Gold to Platinum" && @user.level == User::Levels::GOLD
      level = User::Levels::PLATINUM
      cost = UserUpgrade.upgrade_price
    else
      raise "Invalid desc"
    end

    begin
      charge = Stripe::Charge.create(
        :amount => cost,
        :currency => "usd",
        :card => params[:stripeToken],
        :description => params[:desc]
      )
      @user.promote_to!(level, is_upgrade: true)
      flash[:success] = true
    rescue Stripe::CardError => e
      DanbooruLogger.log(e)
      flash[:error] = e.message
    end

    if @user == CurrentUser.user
      redirect_to user_upgrade_path
    else
      redirect_to user_upgrade_path(user_id: params[:user_id])
    end
  end
end
