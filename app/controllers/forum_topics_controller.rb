class ForumTopicsController < ApplicationController
  respond_to :html, :xml, :json
  respond_to :atom, only: [:index, :show]
  before_action :normalize_search, :only => :index
  skip_before_action :api_check

  def new
    @forum_topic = authorize ForumTopic.new
    @forum_topic.original_post = ForumPost.new
    respond_with(@forum_topic)
  end

  def edit
    @forum_topic = authorize ForumTopic.find(params[:id])
    respond_with(@forum_topic)
  end

  def index
    params[:search] ||= {}
    params[:search][:order] ||= "sticky" if request.format.html?
    params[:limit] ||= 40

    @forum_topics = authorize ForumTopic.visible(CurrentUser.user).paginated_search(params)

    if request.format.atom?
      @forum_topics = @forum_topics.includes(:creator, :original_post)
    elsif request.format.html?
      @forum_topics = @forum_topics.includes(:creator, :updater, :forum_topic_visit_by_current_user, :bulk_update_requests)
    end

    respond_with(@forum_topics)
  end

  def show
    @forum_topic = authorize ForumTopic.find(params[:id])

    if request.format.html?
      @forum_topic.mark_as_read!(CurrentUser.user)
    end

    @forum_posts = @forum_topic.forum_posts.order(id: :asc).paginate(params[:page], limit: params[:limit])

    if request.format.atom?
      @forum_posts = @forum_posts.reverse_order.load
    elsif request.format.html?
      @forum_posts = @forum_posts.includes(:creator, :bulk_update_request)
    end

    respond_with(@forum_topic)
  end

  def create
    @forum_topic = authorize ForumTopic.new(permitted_attributes(ForumTopic))
    @forum_topic.creator = CurrentUser.user
    @forum_topic.original_post.creator = CurrentUser.user
    @forum_topic.save

    respond_with(@forum_topic)
  end

  def update
    @forum_topic = authorize ForumTopic.find(params[:id])
    @forum_topic.update(permitted_attributes(@forum_topic))
    respond_with(@forum_topic)
  end

  def destroy
    @forum_topic = authorize ForumTopic.find(params[:id])
    @forum_topic.update(is_deleted: true)
    @forum_topic.create_mod_action_for_delete
    flash[:notice] = "Topic deleted"
    respond_with(@forum_topic)
  end

  def undelete
    @forum_topic = authorize ForumTopic.find(params[:id])
    @forum_topic.update(is_deleted: false)
    @forum_topic.create_mod_action_for_undelete
    flash[:notice] = "Topic undeleted"
    respond_with(@forum_topic)
  end

  def mark_all_as_read
    authorize ForumTopic
    CurrentUser.user.update_attribute(:last_forum_read_at, Time.now)
    ForumTopicVisit.prune!(CurrentUser.user)
    redirect_to forum_topics_path, :notice => "All topics marked as read"
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
end
