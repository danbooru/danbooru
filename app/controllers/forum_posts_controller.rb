class ForumPostsController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_action :member_only, :except => [:index, :show, :search]
  before_action :load_post, :only => [:edit, :show, :update, :destroy, :undelete]
  before_action :check_min_level, :only => [:edit, :show, :update, :destroy, :undelete]
  skip_before_action :api_check

  def new
    if params[:topic_id]
      @forum_topic = ForumTopic.find(params[:topic_id])
      raise User::PrivilegeError.new unless @forum_topic.visible?(CurrentUser.user)
    end
    if params[:post_id]
      quoted_post = ForumPost.find(params[:post_id])
      raise User::PrivilegeError.new unless quoted_post.topic.visible?(CurrentUser.user)
    end
    @forum_post = ForumPost.new_reply(params)
    respond_with(@forum_post)
  end

  def edit
    check_privilege(@forum_post)
    respond_with(@forum_post)
  end

  def index
    @forum_posts = ForumPost.paginated_search(params).includes(model_includes(params))
    respond_with(@forum_posts)
  end

  def search
  end

  def show
    respond_with(@forum_post) do |format|
      format.html do
        page = @forum_post.forum_topic_page
        page = nil if page == 1
        redirect_to forum_topic_path(@forum_post.topic, page: page, anchor: "forum_post_#{@forum_post.id}")
      end
    end
  end

  def create
    @forum_post = ForumPost.create(forum_post_params(:create).merge(creator: CurrentUser.user))
    page = @forum_post.topic.last_page if @forum_post.topic.last_page > 1
    respond_with(@forum_post, :location => forum_topic_path(@forum_post.topic, :page => page))
  end

  def update
    check_privilege(@forum_post)
    @forum_post.update(forum_post_params(:update))
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

  def default_includes(params)
    if ["json", "xml"].include?(params[:format])
      []
    else
      [:topic, :creator]
    end
  end

  def load_post
    @forum_post = ForumPost.find(params[:id])
    @forum_topic = @forum_post.topic
  end

  def check_min_level
    raise User::PrivilegeError if CurrentUser.user.level < @forum_topic.min_level
  end

  def check_privilege(forum_post)
    if !forum_post.editable_by?(CurrentUser.user)
      raise User::PrivilegeError
    end
  end

  def forum_post_params(context)
    permitted_params = [:body]
    permitted_params += [:topic_id] if context == :create

    params.require(:forum_post).permit(permitted_params)
  end
end
