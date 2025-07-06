# frozen_string_literal: true

class ForumTopicsController < ApplicationController
  respond_to :html, :xml, :json
  respond_to :atom, only: [:index, :show]

  before_action :normalize_search, :only => :index
  before_action if: -> { request.format.html? && !Danbooru.config.forum_enabled?.to_s.truthy? } do
    redirect_to root_path
  end

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
    if request.format.html?
      limit = params.fetch(:limit, 40)
      @forum_topics = authorize ForumTopic.visible(CurrentUser.user).paginated_search(params, limit: limit, defaults: { order: "sticky", is_deleted: "false" })
    else
      @forum_topics = authorize ForumTopic.visible(CurrentUser.user).paginated_search(params)
    end

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

    @forum_posts = @forum_topic.forum_posts.order(id: :asc).paginate(params[:page], limit: params[:limit], page_limit: 5_000)

    if request.format.atom?
      @forum_posts = @forum_posts.reverse_order.load
    end

    respond_with(@forum_topic)
  end

  def create
    @forum_topic = authorize ForumTopic.new(permitted_attributes(ForumTopic).deep_merge(
      creator: CurrentUser.user,
      original_post_attributes: {
        creator: CurrentUser.user,
        creator_ip_addr: request.remote_ip,
      },
    ))
    @forum_topic.save

    respond_with(@forum_topic)
  end

  def update
    @forum_topic = authorize ForumTopic.find(params[:id])
    @forum_topic.update(updater: CurrentUser.user, **permitted_attributes(@forum_topic))
    respond_with(@forum_topic)
  end

  def destroy
    @forum_topic = authorize ForumTopic.find(params[:id])
    @forum_topic.soft_delete!(updater: CurrentUser.user)

    respond_with(@forum_topic, notice: "Topic deleted")
  end

  def undelete
    @forum_topic = authorize ForumTopic.find(params[:id])
    @forum_topic.undelete!(updater: CurrentUser.user)

    respond_with(@forum_topic, notice: "Topic undeleted")
  end

  def mark_all_as_read
    authorize ForumTopic
    CurrentUser.user.update(last_forum_read_at: Time.zone.now)
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
