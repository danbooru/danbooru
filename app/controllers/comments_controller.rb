class CommentsController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :member_only, :only => [:update, :create, :edit]

  def index
    if params[:group_by] == "post"
      index_by_post
    else
      index_by_comment
    end
  end
  
  def search
    @search = Comment.search(params[:search])
  end
  
  def update
    @comment = Comment.find(params[:id])
    @comment.update_attributes(params[:comment])
    respond_with(@comment, :location => post_path(@comment.post_id))
  end
  
  def create
    @comment = Comment.create(params[:comment])
    respond_with(@comment) do |format|
      format.html do
        redirect_to post_path(@comment.post), :notice => "Comment posted"
      end
    end
  end
  
  def edit
    @comment = Comment.find(params[:id])
    respond_with(@comment)
  end
  
private
  def index_by_post
    @posts = Post.commented_before(Time.now).tag_match(params[:tags]).paginate(params[:page])
    respond_with(@posts) do |format|
      format.html {render :action => "index_by_post"}
    end
  end
  
  def index_by_comment
    @search = Comment.search(params[:search])
    @comments = @search.paginate(params[:page])
    respond_with(@comments) do |format|
      format.html {render :action => "index_by_comment"}
    end
  end
end
