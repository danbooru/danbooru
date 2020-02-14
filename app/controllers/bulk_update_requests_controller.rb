class BulkUpdateRequestsController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_action :member_only, :except => [:index, :show]
  before_action :admin_only, :only => [:approve]
  before_action :load_bulk_update_request, :except => [:new, :create, :index]

  def new
    @bulk_update_request = BulkUpdateRequest.new(bur_params(:create))
    respond_with(@bulk_update_request)
  end

  def create
    @bulk_update_request = BulkUpdateRequest.create(bur_params(:create).merge(user: CurrentUser.user))
    respond_with(@bulk_update_request, :location => bulk_update_requests_path)
  end

  def show
    respond_with(@bulk_update_request)
  end

  def edit
  end

  def update
    raise User::PrivilegeError unless @bulk_update_request.editable?(CurrentUser.user)

    @bulk_update_request.update(bur_params(:update))
    respond_with(@bulk_update_request, location: bulk_update_requests_path, notice: "Bulk update request updated")
  end

  def approve
    @bulk_update_request.approve!(CurrentUser.user)
    respond_with(@bulk_update_request, :location => bulk_update_requests_path)
  end

  def destroy
    raise User::PrivilegeError unless @bulk_update_request.rejectable?(CurrentUser.user)

    @bulk_update_request.reject!(CurrentUser.user)
    respond_with(@bulk_update_request, location: bulk_update_requests_path, notice: "Bulk update request rejected")
  end

  def index
    @bulk_update_requests = BulkUpdateRequest.paginated_search(params, count_pages: true).includes(model_includes(params))
    respond_with(@bulk_update_requests)
  end

  private

  def default_includes(params)
    if ["json", "xml"].include?(params[:format])
      []
    else
      [:user, :approver, :forum_topic, {forum_post: [:votes]}]
    end
  end

  def load_bulk_update_request
    @bulk_update_request = BulkUpdateRequest.find(params[:id])
  end

  def bur_params(context)
    permitted_params = %i[script skip_secondary_validations]
    permitted_params += %i[title reason forum_topic_id] if context == :create
    permitted_params += %i[forum_topic_id forum_post_id] if context == :update && CurrentUser.is_admin?

    params.fetch(:bulk_update_request, {}).permit(permitted_params)
  end
end
