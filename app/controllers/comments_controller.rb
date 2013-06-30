class CommentsController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :member_only, :only => [:update, :create, :edit, :destroy]
  rescue_from ActiveRecord::StatementInvalid, :with => :search_error

  def index
    if params[:group_by] == "comment"
      index_by_comment
    elsif request.format == Mime::JS
      index_for_post
    else
      index_by_post
    end
  end

  def search
  end

  def new
    redirect_to comments_path
  end

  def update
    @comment = Comment.find(params[:id])
    check_privilege(@comment)
    @comment.update_attributes(params[:comment])
    respond_with(@comment, :location => post_path(@comment.post_id))
  end

  def create
    @comment = Comment.create(params[:comment])
    respond_with(@comment) do |format|
      format.html do
        if @comment.errors.any?
          redirect_to post_path(@comment.post), :notice => @comment.errors.full_messages.join("; ")
        else
          redirect_to post_path(@comment.post), :notice => "Comment posted"
        end
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
      format.json {render :json => @comment.to_json(:methods => [:creator_name])}
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    check_privilege(@comment)
    @comment.destroy
    respond_with(@comment) do |format|
      format.js
    end
  end

  def unvote
    @comment = Comment.find(params[:id])
    @comment.unvote!
  rescue CommentVote::Error => x
    @error = x
  end

private
  def index_for_post
    @post = Post.find(params[:post_id])
    @comments = @post.comments
    @comments = @comments.visible(CurrentUser.user) unless params[:include_below_threshold]
    render :action => "index_for_post"
  end

  def index_by_post
    @posts = Post.commented_before(Time.now).tag_match(params[:tags]).paginate(params[:page], :limit => 5, :search_count => params[:search])
    @posts.all
    respond_with(@posts) do |format|
      format.html {render :action => "index_by_post"}
      format.xml do
        render :xml => @posts.to_xml(:root => "posts")
      end
    end
  end

  def index_by_comment
    @comments = Comment.search(params[:search]).order("comments.id DESC").paginate(params[:page], :limit => params[:limit], :search_count => params[:search])
    respond_with(@comments) do |format|
      format.html {render :action => "index_by_comment"}
      format.xml do
        render :xml => @comments.to_xml(:root => "comments")
      end
    end
  end

  def check_privilege(comment)
    if !comment.editable_by?(CurrentUser.user)
      raise User::PrivilegeError
    end
  end

protected
  def search_error(e)
    if e.message =~ /syntax error in tsquery/
      @error_message = "Meta-tags are not supported in comment searches by tag"
      render :template => "static/error", :status => 500
    else
      rescue_exception(e)
    end
  end
end
