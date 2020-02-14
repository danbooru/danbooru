class PostApprovalsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @post_approvals = PostApproval.paginated_search(params).includes(model_includes(params))
    respond_with(@post_approvals)
  end

  private

  def default_includes(params)
    if ["json", "xml"].include?(params[:format])
      []
    else
      [:user, {post: [:uploader]}]
    end
  end
end
