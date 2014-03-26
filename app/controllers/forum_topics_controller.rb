class ForumTopicsController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :member_only, :except => [:index, :show]
  before_filter :janitor_only, :only => [:new_merge, :create_merge]
  before_filter :normalize_search, :only => :index

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
    # session[:read_forum_topics] = ""
    @query = ForumTopic.active.search(params[:search])
    @forum_topics = @query.order("is_sticky DESC, updated_at DESC").paginate(params[:page], :limit => params[:limit], :search_count => params[:search])
    @read_forum_topic_ids = read_forum_topic_ids
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
    unless CurrentUser.user.is_anonymous?
      session[:read_forum_topics] = @forum_topic.mark_as_read(read_forum_topic_ids)
    end
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
    session[:read_forum_topics] = ""
    redirect_to forum_topics_path, :notice => "All topics marked as read"
  end

  def new_merge
    @forum_topic = ForumTopic.find(params[:id])
  end

  def create_merge
    @forum_topic = ForumTopic.find(params[:id])
    @merged_topic = ForumTopic.find(params[:merged_id])
    @forum_topic.merge(@merged_topic)
    redirect_to forum_topic_path(@forum_topic)
  end

private
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

  def read_forum_topics
    session[:read_forum_topics].to_s
  end

  def read_forum_topic_ids
    read_forum_topics.scan(/(\S+) (\S+)/)
  end

  def check_privilege(forum_topic)
    if !forum_topic.editable_by?(CurrentUser.user)
      raise User::PrivilegeError
    end
  end
end
