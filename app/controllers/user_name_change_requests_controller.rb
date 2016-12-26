class UserNameChangeRequestsController < ApplicationController
  before_filter :member_only, :only => [:index, :show]
  before_filter :gold_only, :only => [:new, :create]
  before_filter :admin_only, :only => [:approve, :reject]
  respond_to :html, :json, :xml

  def new
  end
  
  def create
    @change_request = UserNameChangeRequest.create(
      :user_id => CurrentUser.user.id,
      :original_name => CurrentUser.user.name,
      :status => "pending",
      :change_reason => params[:reason],
      :desired_name => params[:desired_name]
    )
    
    if @change_request.errors.any?
      render :action => "new"
    else
      @change_request.approve! 
      redirect_to user_name_change_request_path(@change_request), :notice => "Your name has been changed"
    end
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
  
  def approve
    @change_request = UserNameChangeRequest.find(params[:id])
    @change_request.approve!
    redirect_to user_name_change_request_path(@change_request), :notice => "Name change request approved"
  end
  
  def reject
    @change_request = UserNameChangeRequest.find(params[:id])
    @change_request.reject!(params[:reason])
    redirect_to user_name_change_request_path(@change_request), :notice => "Name change request rejected"
  end

private
  def check_privileges!(change_request)
    return if CurrentUser.is_admin?
    raise User::PrivilegeError if change_request.user_id != CurrentUser.user.id
  end
end
