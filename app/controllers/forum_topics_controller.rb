class ForumTopicsController < ApplicationController
  respond_to :html, :xml, :json
  respond_to :atom, only: [:index, :show]
  before_action :member_only, :except => [:index, :show]
  before_action :normalize_search, :only => :index
  before_action :load_topic, :only => [:edit, :show, :update, :destroy, :undelete]
  before_action :check_min_level, :only => [:show, :edit, :update, :destroy, :undelete]
  skip_before_action :api_check

  def new
    @forum_topic = ForumTopic.new
    @forum_topic.original_post = ForumPost.new
    respond_with(@forum_topic)
  end

  def edit
    check_privilege(@forum_topic)
    respond_with(@forum_topic)
  end

  def index
    params[:search] ||= {}
    params[:search][:order] ||= "sticky" if request.format.html?
    params[:limit] ||= 40

    @forum_topics = ForumTopic.paginated_search(params)

    if request.format.atom?
      @forum_topics = @forum_topics.includes(:creator, :original_post)
    elsif request.format.html?
      @forum_topics = @forum_topics.includes(:creator, :updater, :forum_topic_visit_by_current_user, :bulk_update_requests)
    end

    respond_with(@forum_topics)
  end

  def show
    if request.format.html?
      @forum_topic.mark_as_read!(CurrentUser.user)
    end

    @forum_posts = ForumPost.search(:topic_id => @forum_topic.id).reorder("forum_posts.id").paginate(params[:page])

    if request.format.atom?
      @forum_posts = @forum_posts.reverse_order.load
    elsif request.format.html?
      @forum_posts = @forum_posts.includes(:creator, :bulk_update_request)
    end

    respond_with(@forum_topic)
  end

  def create
    @forum_topic = ForumTopic.new(forum_topic_params(:create))
    @forum_topic.creator = CurrentUser.user
    @forum_topic.original_post.creator = CurrentUser.user
    @forum_topic.save

    respond_with(@forum_topic)
  end

  def update
    check_privilege(@forum_topic)
    @forum_topic.update(forum_topic_params(:update))
    respond_with(@forum_topic)
  end

  def destroy
    check_privilege(@forum_topic)
    @forum_topic.delete!
    @forum_topic.create_mod_action_for_delete
    flash[:notice] = "Topic deleted"
    respond_with(@forum_topic)
  end

  def undelete
    check_privilege(@forum_topic)
    @forum_topic.undelete!
    @forum_topic.create_mod_action_for_undelete
    flash[:notice] = "Topic undeleted"
    respond_with(@forum_topic)
  end

  def mark_all_as_read
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

  def check_privilege(forum_topic)
    if !forum_topic.editable_by?(CurrentUser.user)
      raise User::PrivilegeError
    end
  end

  def load_topic
    @forum_topic = ForumTopic.find(params[:id])
  end

  def check_min_level
    raise User::PrivilegeError if CurrentUser.user.level < @forum_topic.min_level
  end

  def forum_topic_params(context)
    permitted_params = [:title, :category_id, { original_post_attributes: %i[id body] }]
    permitted_params += %i[is_sticky is_locked min_level] if CurrentUser.is_moderator?

    params.require(:forum_topic).permit(permitted_params)
  end
end
