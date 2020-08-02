class EmailsController < ApplicationController
  respond_to :html, :xml, :json

  def show
    @email_address = authorize EmailAddress.find_by_user_id!(params[:user_id])
    respond_with(@email_address)
  end

  def edit
    @user = authorize User.find(params[:user_id]), policy_class: EmailAddressPolicy
    respond_with(@user)
  end

  def update
    @user = authorize User.find(params[:user_id]), policy_class: EmailAddressPolicy

    if @user.authenticate_password(params[:user][:password])
      @user.update(email_address_attributes: { address: params[:user][:email] })
    else
      @user.errors[:base] << "Password was incorrect"
    end

    if @user.errors.none?
      flash[:notice] = "Email updated. Check your email to confirm your new address"
      UserMailer.email_change_confirmation(@user).deliver_later
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
    elsif params[:email_verification_key].present?
      authorize @email_address
      @email_address.update!(is_verified: true)
      flash[:notice] = "Email address verified"
      redirect_to @email_address.user
    else
      authorize @email_address
      respond_with(@user)
    end
  end

  def send_confirmation
    @user = authorize User.find(params[:user_id]), policy_class: EmailAddressPolicy
    UserMailer.welcome_user(@user).deliver_later

    flash[:notice] = "Confirmation email sent to #{@user.email_address.address}. Check your email to confirm your address"
    redirect_to @user
  end
end
