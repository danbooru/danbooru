# frozen_string_literal: true

class UsersController < ApplicationController
  respond_to :html, :xml, :json

  rate_limit :create, rate: 1.0/5.minutes, burst: 10

  def new
    @user = authorize User.new
    @user.email_address = EmailAddress.new
    respond_with(@user)
  end

  def edit
    @user = authorize User.find(params[:id])
    respond_with(@user)
  end

  def settings
    @user = authorize CurrentUser.user

    if @user.is_anonymous?
      redirect_to login_path(url: settings_path)
    else
      params[:action] = "edit"
      respond_with(@user, template: "users/edit")
    end
  end

  def index
    if params[:name].present?
      params[:search] ||= {}
      params[:search][:name_or_past_name_matches] = params[:name]
      params[:redirect] = "true"
    end

    @users = authorize User.paginated_search(params)
    @users = @users.includes(:inviter) if request.format.html?

    if params[:variant] == "tooltip" && !@users.load.one?
      render status: 404
    else
      respond_with(@users)
    end
  end

  def show
    @user = authorize User.find(params[:id])
    respond_with(@user, methods: @user.full_attributes) do |format|
      format.html.tooltip { render layout: false }
    end
  end

  def profile
    @user = authorize CurrentUser.user

    if !@user.is_anonymous? || request.format.json? || request.format.xml?
      params[:action] = "show"
      respond_with(@user, methods: @user.full_attributes, template: "users/show")
    else
      redirect_to login_path(url: profile_path)
    end
  end

  def create
    user_verifier = UserVerifier.new(CurrentUser.user, request)

    @user = authorize User.new(
      last_ip_addr: request.remote_ip,
      last_logged_in_at: Time.zone.now,
      requires_verification: user_verifier.requires_verification?,
      level: user_verifier.initial_level,
      name: params[:user][:name],
      password: params[:user][:password],
      password_confirmation: params[:user][:password_confirmation]
    )

    user_verifier.log! if user_verifier.requires_verification?
    UserEvent.build_from_request(@user, :user_creation, request)

    if params[:user][:email_address].present?
      @user.email_address = EmailAddress.new(address: params[:user][:email_address])
    end

    if !CaptchaService.new.verify_request(request)
      @user.errors.add(:base, "Invalid captcha, try again.")
    elsif @user.email_address&.valid? && @user.email_address&.invalid?(:deliverable)
      @user.errors.add(:email_address, "is invalid or can't receive mail")
    elsif @user.save
      session[:user_id] = @user.id
      UserMailer.with_request(request).welcome_user(@user).deliver_later
      set_current_user
    end

    respond_with(@user)
  end

  def update
    @user = authorize User.find(params[:id])
    @user.update(permitted_attributes(@user))

    if @user.errors.any?
      flash[:notice] = @user.errors.full_messages.join("; ")
    else
      flash[:notice] = "Settings updated"
    end

    respond_with(@user) do |format|
      format.html { redirect_back fallback_location: edit_user_path(@user) }
    end
  end

  def deactivate
    if params[:id].present?
      @user = authorize User.find(params[:id])
    else
      @user = authorize CurrentUser.user
    end

    respond_with(@user)
  end

  def destroy
    @user = authorize User.find(params[:id])

    user_deletion = UserDeletion.new(user: @user, deleter: CurrentUser.user, password: params.dig(:user, :password), request: request)
    user_deletion.delete!

    if user_deletion.errors.none?
      flash[:notice] = "Your account has been deactivated"
      respond_with(user_deletion, location: posts_path)
    else
      flash[:notice] = user_deletion.errors.full_messages.join("; ")
      redirect_to deactivate_user_path(@user)
    end
  end

  def custom_style
    @custom_css = CurrentUser.user.custom_css
    expires_in 10.years
  end

  private

  def item_matches_params(user)
    if params[:search][:name_matches]
      User.normalize_name(user.name) == User.normalize_name(params[:search][:name_matches])
    else
      true
    end
  end
end
