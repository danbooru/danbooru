class UserUpgradesController < ApplicationController
  before_filter :member_only, :only => [:new, :show]
  helper_method :encrypt_custom, :coinbase, :user
  #force_ssl :if => :ssl_enabled?
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    if params[:stripeToken]
      create_stripe
    elsif params[:order]
      create_coinbase
    end
  end

  def new
    unless CurrentUser.user.is_anonymous?
      TransactionLogItem.record_account_upgrade_view(CurrentUser.user, request.referer)
    end
  end

  def show
  end

  def encrypt_custom(level)
    crypt.encrypt_and_sign("#{user.id},#{level}")
  end

  def coinbase
    @coinbase_api ||= Coinbase::Client.new(Danbooru.config.coinbase_api_key, Danbooru.config.coinbase_api_secret)
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
      cost = 2000
    elsif params[:desc] == "Upgrade to Platinum"
      level = User::Levels::PLATINUM
      cost = 4000
    elsif params[:desc] == "Upgrade Gold to Platinum" && @user.level == User::Levels::GOLD
      level = User::Levels::PLATINUM
      cost = 2000
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
      @user.promote_to!(level, :skip_feedback => true)
      flash[:success] = true
    rescue Stripe::CardError => e
      flash[:error] = e.message
    end

    redirect_to user_upgrade_path
  end

  def create_coinbase
    if params[:order][:status] == "completed"
      user_id, level = decrypt_custom
      member = User.find(user_id)

      if member.level < User::Levels::PLATINUM && level >= User::Levels::GOLD && level <= User::Levels::PLATINUM
        CurrentUser.scoped(User.admins.first, "127.0.0.1") do
          member.promote_to!(level, :skip_feedback => true)
        end
      end
    end

    render :nothing => true
  end

  def decrypt_custom
    crypt.decrypt_and_verify(params[:order][:custom]).split(/,/).map(&:to_i)
  end

  def crypt
    ActiveSupport::MessageEncryptor.new(Danbooru.config.coinbase_secret)
  end

  def ssl_enabled?
    !Rails.env.development? && !Rails.env.test?
  end
end
