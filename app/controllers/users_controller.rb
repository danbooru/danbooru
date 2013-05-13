class UsersController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :member_only, :only => [:edit, :update, :upgrade]
  rescue_from User::PrivilegeError, :with => :access_denied

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
      redirect_to user_path(@user)
    else
      @users = User.search(params[:search]).order("users.id desc").paginate(params[:page], :search_count => params[:search])
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
    respond_with(@user)
  end

  def create
    @user = User.create(params[:user], :as => CurrentUser.role)
    if @user.errors.empty?
      session[:user_id] = @user.id
    end
    set_current_user
    respond_with(@user)
  end

  def update
    @user = User.find(params[:id])
    check_privilege(@user)
    sanitize_params!
    @user.update_attributes(params[:user], :as => CurrentUser.role)
    respond_with(@user)
  end

  def upgrade
    @user = User.find(params[:id])

    if params[:email] =~ /paypal/
      UserMailer.upgrade_fail(params[:email]).deliver
    else
      UserMailer.upgrade(@user, params[:email]).deliver
    end

    redirect_to user_path(@user), :notice => "Email was sent"
  end

  def cache
    @user = User.find(params[:id])
    @user.update_cache
    render :nothing => true
  end

private
  def sanitize_params!
    return if CurrentUser.is_admin?
    
    if params[:user] && params[:user][:level].to_i >= User::Levels::MODERATOR
      params[:user][:level] = User::Levels::JANITOR
    end
  end

  def check_privilege(user)
    raise User::PrivilegeError unless (user.id == CurrentUser.id || CurrentUser.is_admin?)
  end
end
