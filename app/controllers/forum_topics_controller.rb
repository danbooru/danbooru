class ForumTopicsController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :member_only, :except => [:index, :show]
  before_filter :normalize_search, :only => :index
  after_filter :update_last_forum_read_at, :only => [:show]

  def new
    @forum_topic = ForumTopic.new
    @forum_topic.original_post = ForumPost.new
    respond_with(@forum_topic)
  end

  def edit
    @forum_topic = ForumTopic.find(params[:id])
    check_privilege(@forum_topic)
    respond_with(@forum_topic)
  end

  def index
    @query = ForumTopic.active.search(params[:search])
    @forum_topics = @query.order("is_sticky DESC, updated_at DESC").paginate(params[:page], :limit => params[:limit], :search_count => params[:search])
    respond_with(@forum_topics) do |format|
      format.xml do
        render :xml => @forum_topics.to_xml(:root => "forum-topics")
      end
    end
  end

  def show
    @forum_topic = ForumTopic.find(params[:id])
    @forum_posts = ForumPost.search(:topic_id => @forum_topic.id).order("forum_posts.id").paginate(params[:page])
    @forum_posts.all
    respond_with(@forum_topic)
  end

  def create
    @forum_topic = ForumTopic.create(params[:forum_topic], :as => CurrentUser.role)
    respond_with(@forum_topic)
  end

  def update
    @forum_topic = ForumTopic.find(params[:id])
    check_privilege(@forum_topic)
    @forum_topic.update_attributes(params[:forum_topic], :as => CurrentUser.role)
    respond_with(@forum_topic)
  end

  def destroy
    @forum_topic = ForumTopic.find(params[:id])
    check_privilege(@forum_topic)
    @forum_topic.update_column(:is_deleted, true)
    flash[:notice] = "Topic deleted"
    respond_with(@forum_topic)
  end

  def undelete
    @forum_topic = ForumTopic.find(params[:id])
    check_privilege(@forum_topic)
    @forum_topic.update_column(:is_deleted, false)
    flash[:notice] = "Topic undeleted"
    respond_with(@forum_topic)
  end

  def mark_all_as_read
    CurrentUser.user.update_attribute(:last_forum_read_at, Time.now)
    redirect_to forum_topics_path, :notice => "All topics marked as read"
  end

private
  def update_last_forum_read_at
    return if CurrentUser.is_anonymous?

    if CurrentUser.last_forum_read_at.nil? || CurrentUser.last_forum_read_at < @forum_topic.updated_at
      CurrentUser.update_column(:last_forum_read_at, @forum_topic.updated_at)
    end
  end

  def normalize_search
    if params[:title_matches]
      params[:search] ||= {}
      params[:search][:title_matches] = params.delete(:title_matches)
    end

    if params[:title]
      params[:search] ||= {}
      params[:search][:title] = params.delete(:title)
    end
  end

  def check_privilege(forum_topic)
    if !forum_topic.editable_by?(CurrentUser.user)
      raise User::PrivilegeError
    end
  end
end
