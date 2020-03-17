class BulkUpdateRequestsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def new
    @bulk_update_request = authorize BulkUpdateRequest.new(permitted_attributes(BulkUpdateRequest))
    respond_with(@bulk_update_request)
  end

  def create
    @bulk_update_request = authorize BulkUpdateRequest.new(user: CurrentUser.user, **permitted_attributes(BulkUpdateRequest))
    @bulk_update_request.save
    respond_with(@bulk_update_request, :location => bulk_update_requests_path)
  end

  def show
    @bulk_update_request = authorize BulkUpdateRequest.find(params[:id])
    respond_with(@bulk_update_request)
  end

  def edit
    @bulk_update_request = authorize BulkUpdateRequest.find(params[:id])
    respond_with(@bulk_update_request)
  end

  def update
    @bulk_update_request = authorize BulkUpdateRequest.find(params[:id])
    @bulk_update_request.update(permitted_attributes(@bulk_update_request))
    respond_with(@bulk_update_request, location: bulk_update_requests_path, notice: "Bulk update request updated")
  end

  def approve
    @bulk_update_request = authorize BulkUpdateRequest.find(params[:id])
    @bulk_update_request.approve!(CurrentUser.user)
    respond_with(@bulk_update_request, :location => bulk_update_requests_path)
  end

  def destroy
    @bulk_update_request = authorize BulkUpdateRequest.find(params[:id])
    @bulk_update_request.reject!(CurrentUser.user)
    respond_with(@bulk_update_request, location: bulk_update_requests_path, notice: "Bulk update request rejected")
  end

  def index
    @bulk_update_requests = authorize BulkUpdateRequest.paginated_search(params, count_pages: true)
    @bulk_update_requests = @bulk_update_requests.includes(:user, :approver, :forum_topic, forum_post: [:votes]) if request.format.html?
    respond_with(@bulk_update_requests)
  end
end
