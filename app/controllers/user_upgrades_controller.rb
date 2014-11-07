class UserUpgradesController < ApplicationController
  before_filter :member_only

  def create
    if params[:desc] == "Upgrade to Gold"
      level = User::Levels::GOLD
      cost = 2000

    elsif params[:desc] == "Upgrade to Platinum"
      level = User::Levels::PLATINUM
      cost = 4000

    elsif params[:desc] == "Upgrade Gold to Platinum" && CurrentUser.user.level == User::Levels::GOLD
      level = User::Levels::PLATINUM
      cost = 2000

    else
      render :text => "invalid desc", :status => 422
      return
    end

    @user = CurrentUser.user
    stripe_token = params[:stripeToken]

    begin
      charge = Stripe::Charge.create(
        :amount => cost,
        :currency => "usd",
        :card => params[:stripeToken],
        :description => params[:desc]
      )
      @user.promote_to!(level, :skip_feedback => true)
      UserMailer.upgrade(@user, params[:email]).deliver
      flash[:success] = true
    rescue Stripe::CardError => e
      flash[:error] = e.message
    end

    redirect_to user_upgrade_path
  end

  def new
    unless CurrentUser.user.is_anonymous?
      TransactionLogItem.record_account_upgrade_view(CurrentUser.user, request.referer)
    end
  end

  def show
  end
end
