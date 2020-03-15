class UsersController < ApplicationController
  respond_to :html, :xml, :json
  skip_before_action :api_check

  def new
    @user = User.new
    @user.email_address = EmailAddress.new
    respond_with(@user)
  end

  def edit
    @user = User.find(params[:id])
    check_privilege(@user)
    respond_with(@user)
  end

  def settings
    @user = CurrentUser.user

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
      redirect_to user_path(@user)
      return
    end

    @users = User.paginated_search(params)
    @users = @users.includes(:inviter) if request.format.html?

    respond_with(@users)
  end

  def search
  end

  def show
    @user = User.find(params[:id])
    respond_with(@user, methods: @user.full_attributes)
  end

  def profile
    @user = CurrentUser.user

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
    @user = User.new(last_ip_addr: CurrentUser.ip_addr, **user_params(:create))
    if !Danbooru.config.enable_recaptcha? || verify_recaptcha(model: @user)
      @user.save
      if @user.errors.empty?
        session[:user_id] = @user.id
        UserMailer.welcome_user(@user).deliver_later
      else
        flash[:notice] = "Sign up failed: #{@user.errors.full_messages.join("; ")}"
      end
      set_current_user
      respond_with(@user)
    else
      flash[:notice] = "Sign up failed"
      redirect_to new_user_path
    end
  end

  def update
    @user = User.find(params[:id])
    check_privilege(@user)
    @user.update(user_params(:update))
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

  def check_privilege(user)
    raise User::PrivilegeError unless user.id == CurrentUser.id || CurrentUser.is_admin?
  end

  def user_params(context)
    permitted_params = %i[
      password old_password password_confirmation
      comment_threshold default_image_size favorite_tags blacklisted_tags
      time_zone per_page custom_style theme

      receive_email_notifications always_resize_images enable_post_navigation
      new_post_navigation_layout enable_private_favorites
      enable_sequential_post_navigation hide_deleted_posts style_usernames
      enable_auto_complete show_deleted_children
      disable_categorized_saved_searches disable_tagged_filenames
      disable_cropped_thumbnails disable_mobile_gestures
      enable_safe_mode enable_desktop_mode disable_post_tooltips
    ]

    if context == :create
      permitted_params += [:name, { email_address_attributes: [:address] }]
    end

    permitted_params << :level if CurrentUser.is_admin?

    params.require(:user).permit(permitted_params)
  end
end
