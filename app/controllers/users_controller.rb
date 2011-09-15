class UsersController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :member_only, :only => [:edit, :update]
  rescue_from User::PrivilegeError, :with => "static/access_denied"

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
    @search = User.search(params[:search])
    @users = @search.paginate(params[:page])
    respond_with(@users)
  end
  
  def show
    @user = User.find(params[:id])
    @presenter = UserPresenter.new(@user)
    respond_with(@user)
  end
  
  def create
    @user = User.create(params[:user])
    if @user.errors.empty?
      session[:user_id] = @user.id
    end
    set_current_user
    respond_with(@user)
  end
  
  def update
    @user = User.find(params[:id])
    check_privilege(@user)
    @user.update_attributes(params[:user])
    respond_with(@user)
  end

private
  def check_privilege(user)
    raise User::PrivilegeError unless (user.id == CurrentUser.id || CurrentUser.is_admin?)
  end
end
