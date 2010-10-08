class CommentsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @posts = Post.paginate :order => "last_commented_at DESC", :per_page => 8
  end
  
  def update
    @comment = Comment.find(params[:id])
    @comment.update_attributes(params[:comment])
    respond_with(@comment)
  end
  
  def create
    @comment = Comment.new(params[:comment])
    @comment.post_id = params[:comment][:post_id]
    @comment.creator_id = CurrentUser.user.id
    @comment.ip_addr = request.remote_ip
    @comment.score = 0
    @comment.save
    respond_with(@comment) do |format|
      format.html do
        flash[:notice] = "Comment posted"
        redirect_to posts_path(@comment.post)
      end
    end
  end
end
