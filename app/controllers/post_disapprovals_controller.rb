class PostDisapprovalsController < ApplicationController
  before_action :approver_only, only: [:create]
  skip_before_action :api_check
  respond_to :js, :html, :json, :xml

  def create
    @post_disapproval = PostDisapproval.create(user: CurrentUser.user, **post_disapproval_params)
    respond_with(@post_disapproval)
  end

  def index
    @post_disapprovals = PostDisapproval.paginated_search(params)
    @post_disapprovals = @post_disapprovals.includes(:user) if request.format.html?

    respond_with(@post_disapprovals)
  end

  private

  def post_disapproval_params
    params.require(:post_disapproval).permit(%i[post_id reason message])
  end
end
