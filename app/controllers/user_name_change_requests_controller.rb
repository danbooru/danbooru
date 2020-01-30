class UserNameChangeRequestsController < ApplicationController
  before_action :member_only, :only => [:index, :show, :new, :create]
  respond_to :html, :json, :xml

  def new
    @change_request = UserNameChangeRequest.new(change_request_params)
    respond_with(@change_request)
  end

  def create
    @change_request = UserNameChangeRequest.create_with(user: CurrentUser.user, original_name: CurrentUser.name).create(change_request_params)
    flash[:notice] = "Your name has been changed" if @change_request.valid?
    respond_with(@change_request, location: profile_path)
  end

  def show
    @change_request = UserNameChangeRequest.find(params[:id])
    check_privileges!(@change_request)
    respond_with(@change_request)
  end

  def index
    @change_requests = UserNameChangeRequest.visible.order("id desc").paginate(params[:page], :limit => params[:limit])
    respond_with(@change_requests)
  end

  private

  def check_privileges!(change_request)
    return if CurrentUser.is_admin?
    raise User::PrivilegeError if change_request.user_id != CurrentUser.user.id
  end

  def change_request_params
    params.fetch(:user_name_change_request, {}).permit(%i[desired_name desired_name_confirmation])
  end
end
