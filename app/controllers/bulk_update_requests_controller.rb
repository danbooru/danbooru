class BulkUpdateRequestsController < ApplicationController
  respond_to :html
  before_filter :member_only
  before_filter :admin_only, :only => [:update]

  def new
    @bulk_update_request = BulkUpdateRequest.new(:user_id => CurrentUser.user.id)
    respond_with(@bulk_update_request)
  end

  def create
    @bulk_update_request = BulkUpdateRequest.create(params[:bulk_update_request])
    respond_with(@bulk_update_request, :location => bulk_update_requests_path)
  end

  def update
    @bulk_update_request = BulkUpdateRequest.find(params[:id])
    if params[:status] == "approved"
      @bulk_update_request.approve!
    else
      @bulk_update_request.reject!
    end
    flash[:notice] = "Bulk update request updated"
    respond_with(@bulk_update_request, :location => bulk_update_requests_path)
  end

  def index
    @bulk_update_requests = BulkUpdateRequest.paginate(params[:page])
    respond_with(@bulk_update_requests)
  end
end
