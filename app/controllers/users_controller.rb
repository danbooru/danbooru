class UsersController < ApplicationController
  respond_to :html, :xml, :json
  skip_before_action :api_check

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
      @user = User.find_by_name!(params[:name])
      redirect_to user_path(@user, variant: params[:variant])
      return
    end

    @users = authorize User.paginated_search(params)
    @users = @users.includes(:inviter) if request.format.html?

    respond_with(@users)
  end

  def search
  end

  def show
    @user = authorize User.find(params[:id])
    respond_with(@user, methods: @user.full_attributes) do |format|
      format.html.tooltip { render layout: false }
    end
  end

  def profile
    @user = authorize CurrentUser.user

    if @user.is_member?
      params[:action] = "show"
      respond_with(@user, methods: @user.full_attributes, template: "users/show")
    elsif request.format.html?
      redirect_to login_path(url: profile_path)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def create
    requires_verification = IpLookup.new(CurrentUser.ip_addr).is_proxy? || IpBan.hit!(:partial, CurrentUser.ip_addr)

    @user = authorize User.new(
      last_ip_addr: CurrentUser.ip_addr,
      requires_verification: requires_verification,
      name: params[:user][:name],
      password: params[:user][:password],
      password_confirmation: params[:user][:password_confirmation]
    )

    if params[:user][:email].present?
      @user.email_address = EmailAddress.new(address: params[:user][:email])
    end

    if Danbooru.config.enable_recaptcha? && !verify_recaptcha(model: @user)
      flash[:notice] = "Sign up failed"
    elsif @user.email_address&.invalid?(:deliverable)
      flash[:notice] = "Sign up failed: email address is invalid or doesn't exist"
      @user.errors[:base] << @user.email_address.errors.full_messages.join("; ")
    elsif !@user.save
      flash[:notice] = "Sign up failed: #{@user.errors.full_messages.join("; ")}"
    else
      session[:user_id] = @user.id
      UserMailer.welcome_user(@user).deliver_later if @user.can_receive_email?(require_verification: false)
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

  def custom_style
    @css = CustomCss.parse(CurrentUser.user.custom_style)
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
