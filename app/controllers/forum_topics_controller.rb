class ForumTopicsController < ApplicationController
  respond_to :html, :xml, :json
  before_action :member_only, :except => [:index, :show]
  before_action :moderator_only, :only => [:new_merge, :create_merge]
  before_action :normalize_search, :only => :index
  before_action :load_topic, :only => [:edit, :show, :update, :destroy, :undelete, :new_merge, :create_merge, :subscribe, :unsubscribe]
  before_action :check_min_level, :only => [:show, :edit, :update, :new_merge, :create_merge, :destroy, :undelete, :subscribe, :unsubscribe]
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
    params[:search][:order] ||= "sticky" if request.format == Mime::Type.lookup("text/html")

    @query = ForumTopic.active.search(search_params)
    @forum_topics = @query.paginate(params[:page], :limit => per_page, :search_count => params[:search])

    respond_with(@forum_topics) do |format|
      format.html do
        @forum_topics = @forum_topics.includes(:creator, :updater).load
      end
      format.atom do
        @forum_topics = @forum_topics.includes(:creator, :original_post).load
      end
      format.json do
        render :json => @forum_topics.to_json
      end
      format.xml do
        render :xml => @forum_topics.to_xml(:root => "forum-topics")
      end
    end
  end

  def show
    if request.format == Mime::Type.lookup("text/html")
      @forum_topic.mark_as_read!(CurrentUser.user)
    end
    @forum_posts = ForumPost.search(:topic_id => @forum_topic.id).reorder("forum_posts.id").paginate(params[:page])
    respond_with(@forum_topic) do |format|
      format.atom do
        @forum_posts = @forum_posts.reverse_order.includes(:creator).load
      end
    end
  end

  def create
    @forum_topic = ForumTopic.create(forum_topic_params(:create))
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

  def new_merge
  end

  def create_merge
    @merged_topic = ForumTopic.find(params[:merged_id])
    @forum_topic.merge(@merged_topic)
    redirect_to forum_topic_path(@merged_topic)
  end

  def subscribe
    subscription = ForumSubscription.where(:forum_topic_id => @forum_topic.id, :user_id => CurrentUser.user.id).first
    unless subscription
      ForumSubscription.create(:forum_topic_id => @forum_topic.id, :user_id => CurrentUser.user.id, :last_read_at => @forum_topic.updated_at)
    end
    respond_with(@forum_topic)
  end

  def unsubscribe
    subscription = ForumSubscription.where(:forum_topic_id => @forum_topic.id, :user_id => CurrentUser.user.id).first
    if subscription
      subscription.destroy
    end
    respond_with(@forum_topic)
  end

private
  def per_page
    params[:limit] || 40
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

  def load_topic
    @forum_topic = ForumTopic.find(params[:id])
  end

  def check_min_level
    if CurrentUser.user.level < @forum_topic.min_level
      respond_with(@forum_topic) do |fmt|
        fmt.html do
          flash[:notice] = "Access denied"
          redirect_to forum_topics_path
        end

        fmt.json do
          render json: nil, :status => 403
        end

        fmt.xml do
          render xml: nil, :status => 403
        end
      end

      return false
    end
  end

  def forum_topic_params(context)
    permitted_params = [:title, :category_id, { original_post_attributes: %i[id body] }]
    permitted_params += %i[is_sticky is_locked min_level] if CurrentUser.is_moderator?

    params.require(:forum_topic).permit(permitted_params)
  end
end
