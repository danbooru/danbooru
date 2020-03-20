class PostFlagsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def new
    @post_flag = authorize PostFlag.new(permitted_attributes(PostFlag))
    respond_with(@post_flag)
  end

  def index
    @post_flags = authorize PostFlag.paginated_search(params)

    if request.format.html?
      @post_flags = @post_flags.includes(:creator, post: [:flags, :uploader, :approver])
    else
      @post_flags = @post_flags.includes(:post)
    end

    respond_with(@post_flags)
  end

  def create
    @post_flag = authorize PostFlag.new(creator: CurrentUser.user, **permitted_attributes(PostFlag))
    @post_flag.save
    flash[:notice] = @post_flag.errors.none? ? "Post flagged" : @post_flag.errors.full_messages.join("; ")
    respond_with(@post_flag)
  end

  def show
    @post_flag = authorize PostFlag.find(params[:id])
    respond_with(@post_flag) do |fmt|
      fmt.html { redirect_to post_flags_path(search: { id: @post_flag.id }) }
    end
  end
end
