class ForumPostsController < ApplicationController
  def new
    @forum_post = ForumPost.new(:topic_id => params[:topic_id])
  end
  
  def edit
    @forum_post = ForumPost.find(params[:id])
  end

  def show
    @forum_post = ForumPost.find(params[:id])
  end
  
  def create
    @forum_post = ForumPost.new(params[:forum_post])
    if @forum_post.save
      redirect_to forum_post_path(@forum_post)
    else
      render :action => "new"
    end
  end
  
  def update
    @forum_post = ForumPost.find(params[:id])
    if @forum_post.update_attributes(params[:forum_post])
      redirect_to forum_post_path(@forum_post)
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @forum_post = ForumPost.find(params[:id])
    @forum_post.destroy
    redirect_to forum_topic_path(@forum_post.topic_id)
  end
end
