class UserNameChangeRequestsController < ApplicationController
  before_filter :privileged_only, :only => [:new, :create, :show]
  before_filter :admin_only, :only => [:index, :approve, :reject, :destroy]
  rescue_from User::PrivilegeError, :with => :access_denied

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
      redirect_to user_name_change_request_path(@change_request), :notice => "Your request has been submitted and is pending admin review"
    end
  end
  
  def show
    @change_request = UserNameChangeRequest.find(params[:id])
    check_privileges!(@change_request)
  end
  
  def index
    @change_requests = UserNameChangeRequest.order("id desc").paginate(params[:page])
  end
  
  def approve
    @change_request = UserNameChangeRequest.find(params[:id])
    @change_request.approve!
    redirect_to user_name_change_request_path(@change_request), :notice => "Name change request approved"
  end
  
  def destroy
    @change_request = UserNameChangeRequest.find(params[:id])
    @change_request.destroy
    redirect_to user_name_change_requests_path
  end
  
  def reject
    @change_request = UserNameChangeRequest.find(params[:id])
    @change_request.reject!(params[:reason])
    redirect_to user_name_change_request_path(@change_request), :notice => "Name change request rejected"
  end

private
  def check_privileges!(change_request)
    return if CurrentUser.is_janitor?
    raise User::PrivilegeError if change_request.user_id != CurrentUser.user.id
  end
end
