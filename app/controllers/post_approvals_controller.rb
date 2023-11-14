# frozen_string_literal: true

class PostApprovalsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def create
    @approval = authorize PostApproval.new(user: CurrentUser.user, post_id: params[:post_id])
    @approval.save
    respond_with(@approval)
  end

  def index
    @post_approvals = authorize PostApproval.paginated_search(params)
    @post_approvals = @post_approvals.includes(:user, post: [:uploader, :media_asset]) if request.format.html?

    respond_with(@post_approvals)
  end

  def show
    @approval = authorize PostApproval.find(params[:id])

    respond_with(@approval) do |format|
      format.html { redirect_to post_approvals_path(search: { id: @approval.id }) }
    end
  end
end
