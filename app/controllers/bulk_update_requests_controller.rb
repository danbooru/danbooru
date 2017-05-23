class BulkUpdateRequestsController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_filter :member_only
  before_filter :admin_only, :only => [:approve]
  before_filter :load_bulk_update_request, :except => [:new, :create, :index]

  def new
    @bulk_update_request = BulkUpdateRequest.new(:user_id => CurrentUser.user.id)
    respond_with(@bulk_update_request)
  end

  def create
    @bulk_update_request = BulkUpdateRequest.create(params[:bulk_update_request])
    respond_with(@bulk_update_request, :location => bulk_update_requests_path)
  end

  def show
  end

  def edit
  end

  def update
    if @bulk_update_request.editable?(CurrentUser.user)
      @bulk_update_request.update_attributes(params[:bulk_update_request])
      flash[:notice] = "Bulk update request updated"
      respond_with(@bulk_update_request, :location => bulk_update_requests_path)
    else
      access_denied()
    end
  end

  def approve
    @bulk_update_request.approve!(CurrentUser.user)
    respond_with(@bulk_update_request, :location => bulk_update_requests_path)
  end

  def destroy
    if @bulk_update_request.editable?(CurrentUser.user)
      @bulk_update_request.reject!
      flash[:notice] = "Bulk update request rejected"
      respond_with(@bulk_update_request, :location => bulk_update_requests_path)
    else
      access_denied()
    end
  end

  def index
    @bulk_update_requests = BulkUpdateRequest.search(params[:search]).paginate(params[:page], :limit => params[:limit])
    respond_with(@bulk_update_requests)
  end

  private

  def load_bulk_update_request
    @bulk_update_request = BulkUpdateRequest.find(params[:id])
  end
end
