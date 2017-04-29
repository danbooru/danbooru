class UsersController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :member_only, :only => [:edit, :update, :upgrade]
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
      @users = User.search(params[:search]).order("users.id desc").paginate(params[:page], :limit => params[:limit], :search_count => params[:search])
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
    @user = User.new(params[:user], :as => CurrentUser.role)
    @user.last_ip_addr = request.remote_ip
    @user.save
    if @user.errors.empty?
      session[:user_id] = @user.id
    end
    set_current_user
    respond_with(@user)
  end

  def update
    @user = User.find(params[:id])
    check_privilege(@user)
    @user.update_attributes(params[:user].except(:name), :as => CurrentUser.role)
    cookies.delete(:favorite_tags)
    cookies.delete(:favorite_tags_with_categories)
    if @user.errors.any?
      flash[:notice] = @user.errors.full_messages.join("; ")
    else
      flash[:notice] = "Settings updated"
    end
    respond_with(@user)
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
end
