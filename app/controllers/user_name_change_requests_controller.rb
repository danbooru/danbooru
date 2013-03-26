class UserNameChangeRequestsController < ApplicationController
  before_filter :member_only, :only => [:new, :create, :show]
  before_filter :admin_only, :only => [:index, :approve, :reject]

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
    redirect_to user_name_change_request_path(@change_request), :notice => "Your request has been submitted and is pending admin review"
  end
  
  def show
    @change_request = UserNameChangeRequest.find(params[:id])
  end
  
  def index
    @change_requests = UserNameChangeRequest.order("id desc").paginate(params[:page])
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
end
