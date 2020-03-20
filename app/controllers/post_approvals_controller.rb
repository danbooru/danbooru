class PostApprovalsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def create
    @approval = authorize PostApproval.new(user: CurrentUser.user, post_id: params[:post_id])
    @approval.save
    respond_with(@approval)
  end

  def index
    @post_approvals = authorize PostApproval.paginated_search(params)
    @post_approvals = @post_approvals.includes(:user, post: :uploader) if request.format.html?

    respond_with(@post_approvals)
  end
end
