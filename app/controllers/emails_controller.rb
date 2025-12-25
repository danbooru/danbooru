# frozen_string_literal: true

class EmailsController < ApplicationController
  before_action :requires_reauthentication, only: [:edit, :update, :destroy]
  respond_to :html, :xml, :json

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
    @email_address = authorize email_address
    @user = @email_address.user

    respond_with(@email_address)
  end

  def update
    @email_address = authorize email_address
    @email_address.assign_attributes(request: request, updater: CurrentUser.user, **permitted_attributes(@email_address))
    @email_address.save(context: :deliverable)
    @user = @email_address.user

    if @email_address.user == CurrentUser.user
      respond_with(@email_address, notice: "Check your email to confirm your new address", location: settings_path)
    else
      respond_with(@email_address, notice: "Updated email address", location: edit_admin_user_path(@email_address.user))
    end
  end

  def destroy
    @email_address = authorize email_address
    @email_address.attributes = { request: request, updater: CurrentUser.user }
    @email_address.destroy

    respond_with(@email_address, notice: "Email address removed") do |format|
      format.html { redirect_to settings_path, status: 303 }
    end
  end

  def verify
    @user = User.find(params[:user_id])
    @email_address = @user.email_address

    if @email_address.blank?
      skip_authorization
      redirect_to edit_user_email_path(@user)
    elsif params[:email_verification_key].present? && @email_address == EmailAddress.find_signed!(params[:email_verification_key], purpose: "verify")
      skip_authorization
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

  private

  def email_address
    if params[:user_id]
      EmailAddress.find_or_initialize_by(user_id: params[:user_id])
    else
      EmailAddress.find(params[:id])
    end
  end
end
