class CommentsController < ApplicationController
  respond_to :html, :xml, :json, :atom
  respond_to :js, only: [:new, :destroy, :undelete]
  skip_before_action :api_check

  def index
    params[:group_by] ||= "comment" if params[:search].present?

    if params[:group_by] == "comment" || request.format.atom?
      index_by_comment
    elsif request.format.js?
      index_for_post
    else
      index_by_post
    end
  end

  def search
  end

  def new
    if params[:id]
      quoted_comment = Comment.find(params[:id])
      @comment = authorize Comment.new(post_id: quoted_comment.post_id, body: quoted_comment.quoted_response)
    else
      @comment = authorize Comment.new(permitted_attributes(Comment))
    end

    respond_with(@comment)
  end

  def update
    @comment = authorize Comment.find(params[:id])
    @comment.update(permitted_attributes(@comment))
    respond_with(@comment, :location => post_path(@comment.post_id))
  end

  def create
    @comment = authorize Comment.new(creator: CurrentUser.user, creator_ip_addr: CurrentUser.ip_addr)
    @comment.update(permitted_attributes(@comment))
    flash[:notice] = @comment.valid? ? "Comment posted" : @comment.errors.full_messages.join("; ")
    respond_with(@comment) do |format|
      format.html do
        redirect_back fallback_location: (@comment.post || comments_path)
      end
    end
  end

  def edit
    @comment = authorize Comment.find(params[:id])
    respond_with(@comment)
  end

  def show
    @comment = authorize Comment.find(params[:id])

    respond_with(@comment) do |format|
      format.html do
        redirect_to post_path(@comment.post, anchor: "comment_#{@comment.id}")
      end
    end
  end

  def destroy
    @comment = authorize Comment.find(params[:id])
    @comment.update(is_deleted: true)
    respond_with(@comment)
  end

  def undelete
    @comment = authorize Comment.find(params[:id])
    @comment.update(is_deleted: false)
    respond_with(@comment)
  end

  private

  def index_for_post
    @post = Post.find(params[:post_id])
    @comments = @post.comments
    render :action => "index_for_post"
  end

  def index_by_post
    @posts = Post.where("last_comment_bumped_at IS NOT NULL").user_tag_match(params[:tags]).reorder("last_comment_bumped_at DESC NULLS LAST").paginate(params[:page], :limit => 5, :search_count => params[:search])

    if request.format.html?
      @posts = @posts.includes(comments: [:creator])
      @posts = @posts.includes(comments: [:votes]) if CurrentUser.is_member?
    end

    respond_with(@posts)
  end

  def index_by_comment
    @comments = Comment.paginated_search(params)

    if request.format.atom?
      @comments = @comments.includes(:creator, :post)
      @comments = @comments.select { |comment| comment.post.visible? }
    elsif request.format.html?
      @comments = @comments.includes(:creator, :updater, post: :uploader)
      @comments = @comments.includes(:votes) if CurrentUser.is_member?
    end

    respond_with(@comments)
  end
end
