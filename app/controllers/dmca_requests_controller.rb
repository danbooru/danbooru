# frozen_string_literal: true

class DmcaRequestsController < ApplicationController
  respond_to :html, :xml, :json

  before_action :requires_reauthentication

  def index
    @dmca_requests = authorize DmcaRequest.visible(CurrentUser.user).paginated_search(params, count_pages: true)
    respond_with(@dmca_requests)
  end

  def show
    authorize DmcaRequest
    @dmca_request = DmcaRequest.visible(CurrentUser.user).find(params.expect(:id))

    respond_with(@dmca_request)
  end

  def update
    authorize DmcaRequest
    @dmca_request = DmcaRequest.visible(CurrentUser.user).find(params.expect(:id))
    @dmca_request.with_lock { @dmca_request.update(updater: CurrentUser.user, **permitted_attributes(@dmca_request)) }

    respond_with(@dmca_request) do |format|
      format.html { redirect_to dmca_requests_path, notice: @dmca_request.errors.full_messages.to_sentence.presence || "DMCA request ##{@dmca_request.id} marked as #{@dmca_request.status}" }
    end
  end
end
