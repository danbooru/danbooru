class CommentsController < ApplicationController
  respond_to :html, :xml, :json, :atom
  respond_to :js, only: [:new, :destroy, :undelete]
  before_action :member_only, :except => [:index, :search, :show]
  skip_before_action :api_check

  def index
    params[:group_by] ||= "comment" if params[:search].present?

    if params[:group_by] == "comment" || request.format == Mime::Type.lookup("application/atom+xml")
      index_by_comment
    elsif request.format == Mime::Type.lookup("text/javascript")
      index_for_post
    else
      index_by_post
    end
  end

  def search
  end

  def new
    @comment = Comment.new(comment_params(:create))
    @comment.body = Comment.find(params[:id]).quoted_response if params[:id]
    respond_with(@comment)
  end

  def update
    @comment = Comment.find(params[:id])
    check_privilege(@comment)
    @comment.update(comment_params(:update))
    respond_with(@comment, :location => post_path(@comment.post_id))
  end

  def create
    @comment = Comment.create(comment_params(:create).merge(creator: CurrentUser.user, creator_ip_addr: CurrentUser.ip_addr))
    flash[:notice] = @comment.valid? ? "Comment posted" : @comment.errors.full_messages.join("; ")
    respond_with(@comment) do |format|
      format.html do
        redirect_back fallback_location: (@comment.post || comments_path)
      end
    end
  end

  def edit
    @comment = Comment.find(params[:id])
    check_privilege(@comment)
    respond_with(@comment)
  end

  def show
    @comment = Comment.find(params[:id])

    respond_with(@comment) do |format|
      format.html do
        redirect_to post_path(@comment.post, anchor: "comment_#{@comment.id}")
      end
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    check_privilege(@comment)
    @comment.delete!
    respond_with(@comment)
  end

  def undelete
    @comment = Comment.find(params[:id])
    check_privilege(@comment)
    @comment.undelete!
    respond_with(@comment)
  end

  private

  def default_includes(params)
    if ["json", "xml"].include?(params[:format])
      [:creator, :updater]
    elsif params[:format] == "atom"
      [:creator, :post]
    else
      includes_array = [:creator, :updater, {post: [:uploader]}]
      includes_array << :votes if CurrentUser.is_member?
      includes_array
    end
  end

  def index_for_post
    @post = Post.find(params[:post_id])
    @comments = @post.comments
    render :action => "index_for_post"
  end

  def index_by_post
    @posts = Post.where("last_comment_bumped_at IS NOT NULL").tag_match(params[:tags]).reorder("last_comment_bumped_at DESC NULLS LAST").paginate(params[:page], :limit => 5, :search_count => params[:search])

    @posts = @posts.includes(comments: [:creator])
    @posts = @posts.includes(comments: [:votes]) if CurrentUser.is_member?

    respond_with(@posts)
  end

  def index_by_comment
    @comments = Comment.paginated_search(params).includes(model_includes(params))
    respond_with(@comments)
  end

  def check_privilege(comment)
    if !comment.editable_by?(CurrentUser.user)
      raise User::PrivilegeError
    end
  end

  def comment_params(context)
    permitted_params = %i[body post_id]
    permitted_params += %i[do_not_bump_post] if context == :create
    permitted_params += %i[is_deleted] if context == :update
    permitted_params += %i[is_sticky] if CurrentUser.is_moderator?

    params.fetch(:comment, {}).permit(permitted_params)
  end
end
