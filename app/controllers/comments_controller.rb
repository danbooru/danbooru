class CommentsController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :member_only, :only => [:update, :create]

  def index
    @posts = Post.commented_before(params[:before_date] || Time.now).limit(8)
  end
  
  def update
    @comment = Comment.find(params[:id])
    @comment.update_attributes(params[:comment])
    respond_with(@comment)
  end
  
  def create
    @comment = Comment.new(params[:comment])
    @comment.post_id = params[:comment][:post_id]
    @comment.score = 0
    @comment.save
    respond_with(@comment) do |format|
      format.html do
        flash[:notice] = "Comment posted"
        redirect_to posts_path(@comment.post)
      end
      
      format.js
    end
  end
end
