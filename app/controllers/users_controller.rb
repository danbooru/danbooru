class UsersController < ApplicationController
  respond_to :html, :xml, :json
  skip_before_filter :api_check

  def new
    @user = User.new
    respond_with(@user)
  end

  def edit
    @user = User.find(params[:id])
    check_privilege(@user)
    respond_with(@user)
  end

  def index
    if params[:name].present?
      @user = User.find_by_name(params[:name])
      if @user.nil?
        raise "No user found with name: #{params[:name]}"
      else
        redirect_to user_path(@user)
      end
    else
      @users = User.search(params[:search]).paginate(params[:page], :limit => params[:limit], :search_count => params[:search])
      respond_with(@users) do |format|
        format.xml do
          render :xml => @users.to_xml(:root => "users")
        end
      end
    end
  end

  def search
  end

  def show
    @user = User.find(params[:id])
    @presenter = UserPresenter.new(@user)
    respond_with(@user, methods: @user.full_attributes)
  end

  def create
    @user = User.new(user_params(:create))
    if !Danbooru.config.enable_recaptcha? || verify_recaptcha(model: @user)
      @user.save
      if @user.errors.empty?
        session[:user_id] = @user.id
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
    cookies.delete(:favorite_tags)
    cookies.delete(:favorite_tags_with_categories)
    if @user.errors.any?
      flash[:notice] = @user.errors.full_messages.join("; ")
    else
      flash[:notice] = "Settings updated"
    end
    respond_with(@user, location: edit_user_path(@user))
  end

  def cache
    @user = User.find(params[:id])
    @user.update_cache
    render :nothing => true
  end

  private

  def check_privilege(user)
    raise User::PrivilegeError unless (user.id == CurrentUser.id || CurrentUser.is_admin?)
  end

  def user_params(context)
    permitted_params = %i[
      password old_password password_confirmation email
      comment_threshold default_image_size favorite_tags blacklisted_tags
      time_zone per_page custom_style

      receive_email_notifications always_resize_images enable_post_navigation
      new_post_navigation_layout enable_privacy_mode
      enable_sequential_post_navigation hide_deleted_posts style_usernames
      enable_auto_complete show_deleted_children
      disable_categorized_saved_searches disable_tagged_filenames
      enable_recent_searches disable_cropped_thumbnails disable_mobile_gestures
      enable_safe_mode disable_responsive_mode
    ]

    permitted_params += [dmail_filter_attributes: %i[id words]]
    permitted_params << :name if context == :create
    permitted_params << :level if CurrentUser.is_admin?

    params.require(:user).permit(permitted_params)
  end
end
