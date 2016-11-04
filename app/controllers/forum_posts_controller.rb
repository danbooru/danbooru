class ForumPostsController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_filter :member_only, :except => [:index, :show]
  before_filter :load_post, :only => [:edit, :show, :update, :destroy, :undelete]
  before_filter :check_min_level, :only => [:edit, :show, :update, :destroy, :undelete]

  def new
    if params[:topic_id]
      @forum_topic = ForumTopic.find(params[:topic_id]) 
      raise User::PrivilegeError.new unless @forum_topic.visible?(CurrentUser.user)
    end
    @forum_post = ForumPost.new_reply(params)
    respond_with(@forum_post)
  end

  def edit
    check_privilege(@forum_post)
    respond_with(@forum_post)
  end

  def index
    @query = ForumPost.search(params[:search])
    @forum_posts = @query.includes(:topic).order("forum_posts.id DESC").paginate(params[:page], :limit => params[:limit], :search_count => params[:search])
    respond_with(@forum_posts) do |format|
      format.xml do
        render :xml => @forum_posts.to_xml(:root => "forum-posts")
      end
    end
  end

  def search
  end

  def show
    if request.format == "text/html" && @forum_post.id == @forum_post.topic.original_post.id
      redirect_to(forum_topic_path(@forum_post.topic, :page => params[:page]))
    else
      respond_with(@forum_post)
    end
  end

  def create
    @forum_post = ForumPost.create(params[:forum_post])
    page = @forum_post.topic.last_page if @forum_post.topic.last_page > 1
    respond_with(@forum_post, :location => forum_topic_path(@forum_post.topic, :page => page))
  end

  def update
    check_privilege(@forum_post)
    @forum_post.update_attributes(params[:forum_post])
    page = @forum_post.forum_topic_page if @forum_post.forum_topic_page > 1
    respond_with(@forum_post, :location => forum_topic_path(@forum_post.topic, :page => page, :anchor => "forum_post_#{@forum_post.id}"))
  end

  def destroy
    check_privilege(@forum_post)
    @forum_post.delete!
    respond_with(@forum_post)
  end

  def undelete
    check_privilege(@forum_post)
    @forum_post.undelete!
    respond_with(@forum_post)
  end

private
  def load_post
    @forum_post = ForumPost.find(params[:id])
    @forum_topic = @forum_post.topic
  end

  def check_min_level
    if CurrentUser.user.level < @forum_topic.min_level
      respond_with(@forum_topic) do |fmt|
        fmt.html do
          flash[:notice] = "Access denied"
          redirect_to forum_topics_path
        end

        fmt.json do
          render :nothing => true, :status => 403
        end

        fmt.xml do
          render :nothing => true, :status => 403
        end
      end

      return false
    end
  end

  def check_privilege(forum_post)
    if !forum_post.editable_by?(CurrentUser.user)
      raise User::PrivilegeError
    end
  end
end
