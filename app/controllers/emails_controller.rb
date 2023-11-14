# frozen_string_literal: true

class EmailsController < ApplicationController
  before_action :requires_reauthentication, only: [:edit, :update]
  respond_to :html, :xml, :json

  rate_limit :update, rate: 1.0/1.minute, burst: 10

  def index
    @email_addresses = authorize EmailAddress.visible(CurrentUser.user).paginated_search(params, count_pages: true)
    @email_addresses = @email_addresses.includes(:user)
    respond_with(@email_addresses, model: "EmailAddress")
  end

  def show
    if params[:user_id]
      @email_address = authorize EmailAddress.find_by_user_id!(params[:user_id])
    else
      @email_address = authorize EmailAddress.find(params[:id])
    end

    respond_with(@email_address)
  end

  def edit
    @user = authorize User.find(params[:user_id]), policy_class: EmailAddressPolicy
    respond_with(@user)
  end

  def update
    @user = authorize User.find(params[:user_id]), policy_class: EmailAddressPolicy
    @user.change_email(params[:user][:email], request)

    if @user.errors.none?
      flash[:notice] = "Email updated. Check your email to confirm your new address"
      respond_with(@user, location: settings_url)
    else
      flash[:notice] = @user.errors.full_messages.join("; ")
      respond_with(@user)
    end
  end

  def verify
    @user = User.find(params[:user_id])
    @email_address = @user.email_address

    if @email_address.blank?
      redirect_to edit_user_email_path(@user)
    elsif params[:email_verification_key].present? && @email_address == EmailAddress.find_signed!(params[:email_verification_key], purpose: "verify")
      @email_address.verify!
      flash[:notice] = "Email address verified"
      redirect_to @email_address.user
    else
      authorize @email_address
      respond_with(@user)
    end
  end

  def send_confirmation
    @user = authorize User.find(params[:user_id]), policy_class: EmailAddressPolicy
    UserMailer.with_request(request).welcome_user(@user).deliver_later

    flash[:notice] = "Confirmation email sent to #{@user.email_address.address}. Check your email to confirm your address"
    redirect_to @user
  end
end
