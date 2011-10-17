class ForumTopicsController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :member_only, :except => [:index, :show]
  before_filter :normalize_search, :only => :index
  before_filter :update_last_forum_read_at, :only => [:index, :show]
  rescue_from User::PrivilegeError, :with => "static/access_denied"

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
    @search = ForumTopic.search(params[:search])
    @forum_topics = @search.paginate(params[:page]).order("is_sticky DESC, updated_at DESC")
    respond_with(@forum_topics)
  end
  
  def show
    @forum_topic = ForumTopic.find(params[:id])
    @forum_posts = ForumPost.search(:topic_id_eq => @forum_topic.id).paginate(params[:page])
    respond_with(@forum_topic)
  end
  
  def create
    @forum_topic = ForumTopic.create(params[:forum_topic], :as => CurrentUser.role)
    respond_with(@forum_topic)
  end
  
  def update
    @forum_topic = ForumTopic.find(params[:id])
    check_privilege(@forum_topic)
    assign_special_attributes(@forum_topic)
    @forum_topic.update_attributes(params[:forum_topic], :as => CurrentUser.role)
    respond_with(@forum_topic)
  end
  
  def destroy
    @forum_topic = ForumTopic.find(params[:id])
    check_privilege(@forum_topic)
    @forum_topic.destroy
    respond_with(@forum_topic)
  end

private
  def assign_special_attributes(forum_topic)
    return unless CurrentUser.is_moderator?
    
    forum_topic.is_locked = params[:forum_topic][:is_locked]
    forum_topic.is_sticky = params[:forum_topic][:is_sticky]
  end
  
  def update_last_forum_read_at
    return if CurrentUser.last_forum_read_at.present? && CurrentUser.last_forum_read_at > 1.day.ago
    
    CurrentUser.update_column(:last_forum_read_at, Time.now)
  end
  
  def normalize_search
    if params[:title_matches]
      params[:search] ||= {}
      params[:search][:title_matches] = params.delete(:title_matches)
    end
    
    if params[:title]
      params[:search] ||= {}
      params[:search][:title_eq] = params.delete(:title)
    end
  end

  def check_privilege(forum_topic)
    if !forum_topic.editable_by?(CurrentUser.user)
      raise User::PrivilegeError
    end
  end
end
