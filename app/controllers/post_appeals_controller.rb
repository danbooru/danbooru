class PostAppealsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def new
    @post_appeal = authorize PostAppeal.new(permitted_attributes(PostAppeal))
    respond_with(@post_appeal)
  end

  def index
    @post_appeals = authorize PostAppeal.paginated_search(params)

    if request.format.html?
      @post_appeals = @post_appeals.includes(:creator, post: [:appeals, :uploader, :approver])
    else
      @post_appeals = @post_appeals.includes(:post)
    end

    respond_with(@post_appeals)
  end

  def create
    @post_appeal = authorize PostAppeal.new(creator: CurrentUser.user, **permitted_attributes(PostAppeal))
    @post_appeal.save
    flash[:notice] = @post_appeal.errors.none? ? "Post appealed" : @post_appeal.errors.full_messages.join("; ")
    respond_with(@post_appeal)
  end

  def show
    @post_appeal = authorize PostAppeal.find(params[:id])
    respond_with(@post_appeal) do |fmt|
      fmt.html { redirect_to post_appeals_path(search: { id: @post_appeal.id }) }
    end
  end
end
