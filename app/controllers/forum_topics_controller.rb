class ForumTopicsController < ApplicationController
  def new
    @forum_topic = ForumTopic.new
  end
  
  def edit
    @forum_topic = ForumTopic.find(params[:id])
  end
  
  def index
    @search = ForumTopic.search(params[:search])
    @forum_topics = @search.paginate(:page => params[:page], :order => "updated_at DESC")
  end
  
  def show
    @forum_topic = ForumTopic.find(params[:id])
  end
  
  def create
    @forum_topic = ForumTopic.new(params[:forum_topic])
    if @forum_topic.save
      redirect_to forum_topic_path(@forum_topic)
    else
      render :action => "new"
    end
  end
  
  def update
    @forum_topic = ForumTopic.find(params[:id])
    if @forum_topic.update_attributes(params[:forum_topic])
      redirect_to forum_topic_path(@forum_topic)
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @forum_topic = ForumTopic.find(params[:id])
    @forum_topic.destroy
    redirect_to forum_topics_path
  end  
end
