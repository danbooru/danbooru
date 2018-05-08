class PostApprovalsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @post_approvals = PostApproval.includes(:post, :user).search(search_params).paginate(params[:page], limit: params[:limit])
    respond_with(@post_approvals)
  end
end
