# frozen_string_literal: true

class PostDisapprovalsController < ApplicationController
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

  def show
    @post_disapproval = authorize PostDisapproval.find(params[:id])

    respond_with(@post_disapproval) do |format|
      format.html { redirect_to post_disapprovals_path(search: { id: @post_disapproval.id }) }
    end
  end

  def edit
    @post_disapproval = authorize PostDisapproval.find(params[:id])
    respond_with(@post_disapproval)
  end

  def update
    @post_disapproval = authorize PostDisapproval.find(params[:id])
    @post_disapproval.update(permitted_attributes(@post_disapproval))
    respond_with(@post_disapproval) do |fmt|
      fmt.html { redirect_to post_path(@post_disapproval.post) }
    end
  end
end
