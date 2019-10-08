class PostApprovalsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @post_approvals = PostApproval.includes(:post, :user).paginated_search(params)
    respond_with(@post_approvals)
  end
end
