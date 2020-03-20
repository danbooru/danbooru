class PostDisapprovalsController < ApplicationController
  skip_before_action :api_check
  respond_to :js, :html, :json, :xml

  def create
    @post_disapproval = authorize PostDisapproval.new(user: CurrentUser.user, **permitted_attributes(PostDisapproval))
    @post_disapproval.save
    respond_with(@post_disapproval)
  end

  def index
    @post_disapprovals = authorize PostDisapproval.paginated_search(params)
    @post_disapprovals = @post_disapprovals.includes(:user) if request.format.html?

    respond_with(@post_disapprovals)
  end
end
