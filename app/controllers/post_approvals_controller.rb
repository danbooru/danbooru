class PostApprovalsController < ApplicationController
  before_action :approver_only, only: [:create]
  respond_to :html, :xml, :json, :js

  def create
    cookies.permanent[:moderated] = Time.now.to_i
    post = Post.find(params[:post_id])
    @approval = post.approve!
    respond_with(@approval)
  end

  def index
    @post_approvals = PostApproval.paginated_search(params)
    @post_approvals = @post_approvals.includes(:user, post: :uploader) if request.format.html?

    respond_with(@post_approvals)
  end
end
