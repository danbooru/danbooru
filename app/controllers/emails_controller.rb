class EmailsController < ApplicationController
  before_action :member_only
  respond_to :html, :xml, :json

  def edit
    @user = User.find(params[:user_id])
    check_privilege(@user)

    respond_with(@user)
  end

  def update
    @user = User.find(params[:user_id])
    check_privilege(@user)

    if User.authenticate(@user.name, params[:user][:password])
      @user.update(email_address_attributes: { address: params[:user][:email] })
    else
      @user.errors[:base] << "Password was incorrect"
    end

    if @user.errors.none?
      flash[:notice] = "Email updated"
      UserMailer.email_change_confirmation(@user).deliver_later
      respond_with(@user, location: settings_url)
    else
      flash[:notice] = @user.errors.full_messages.join("; ")
      respond_with(@user)
    end
  end

  def verify
    email_id = Danbooru::MessageVerifier.new(:email_verification_key).verify(params[:email_verification_key])
    @email_address = EmailAddress.find(email_id)
    @email_address.update!(is_verified: true)

    flash[:notice] = "Email address verified"
    redirect_to @email_address.user
  end

  private

  def check_privilege(user)
    raise User::PrivilegeError unless user.id == CurrentUser.id || CurrentUser.is_admin?
  end
end
