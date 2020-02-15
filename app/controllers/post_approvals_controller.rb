class PostApprovalsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @post_approvals = PostApproval.paginated_search(params)
    @post_approvals = @post_approvals.includes(:user, post: :uploader) if request.format.html?

    respond_with(@post_approvals)
  end
end
