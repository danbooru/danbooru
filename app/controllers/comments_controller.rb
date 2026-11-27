# frozen_string_literal: true

class CommentsController < ApplicationController
  respond_to :html, :xml, :json, :atom
  respond_to :js, only: [:new, :update, :destroy, :undelete]

  before_action if: -> { request.format.html? && !Danbooru.config.comments_enabled?.to_s.truthy? } do
    redirect_to root_path
  end

  def index
    params[:group_by] ||= "comment" if params[:search].present?

    if params[:group_by] == "comment" || !(request.format.html? || request.format.js?)
      index_by_comment
    elsif request.format.js?
      index_for_post
    else
      index_by_post
    end
  end

  def show
    @comment = authorize Comment.find(params[:id])

    respond_with(@comment) do |format|
      format.html do
        redirect_to post_path(@comment.post, anchor: "comment_#{@comment.id}")
      end
    end
  end

  def new
    if params[:id]
      quoted_comment = authorize Comment.find(params[:id]), :reply?
      @comment = authorize Comment.new(post_id: quoted_comment.post_id, body: quoted_comment.quoted_response)
    else
      @comment = authorize Comment.new(permitted_attributes(Comment))
    end

    respond_with(@comment)
  end

  def edit
    @comment = authorize Comment.find(params[:id])
    respond_with(@comment)
  end

  def create
    @comment = authorize Comment.new(creator: CurrentUser.user, **permitted_attributes(Comment))
    @comment.save

    respond_with(@comment, notice: "Comment posted") do |format|
      format.html { redirect_back_or_to @comment.post } if @comment.persisted?
    end
  end

  def update
    @comment = Comment.find(params[:id])
    @comment.attributes = { updater: CurrentUser.user, **permitted_attributes(@comment) }
    authorize(@comment).save

    respond_with(@comment)
  end

  def destroy
    @comment = authorize Comment.find(params[:id])
    @comment.soft_delete(updater: CurrentUser.user)
    respond_with(@comment)
  end

  def undelete
    @comment = authorize Comment.find(params[:id])
    @comment.undelete(updater: CurrentUser.user)
    respond_with(@comment)
  end

  private

  def index_for_post
    @post = Post.find(params.expect(:post_id))
    @comments = authorize @post.comments
    render action: "index_for_post"
  end

  def index_by_post
    @limit = params.fetch(:limit, 20)
    @posts = Post.where.not(last_comment_bumped_at: nil).user_tag_match(params[:tags]).reorder("last_comment_bumped_at DESC NULLS LAST").paginate(params[:page], limit: @limit, max_limit: 200, search_count: params[:search])
    authorize @posts

    if request.format.html?
      @posts = @posts.includes(:media_asset, :uploader, :vote_by_current_user)
      @tags_by_name = Tag.where(name: @posts.flat_map(&:tag_array).uniq).index_by(&:name)
    end

    respond_with(@posts)
  end

  def index_by_comment
    @comments = authorize Comment.paginated_search(params, max_limit: (request.format.html? || request.format.atom?) ? 200 : 1_000)

    if request.format.atom?
      @comments = @comments.includes(:creator, post: [:media_asset])
      @comments = @comments.select { |comment| policy(comment).show_in_feed? }
      @tags_by_name = Tag.where(name: @comments.flat_map { it.post.tag_array }.uniq).index_by(&:name)
    elsif request.format.html?
      @comments = @comments.includes(:creator, :updater, post: [:uploader, :media_asset])
      @comments = @comments.includes(:active_votes) if CurrentUser.is_member?
      @comments = @comments.includes(:pending_moderation_reports) if policy(ModerationReport).can_see_moderation_reports?
    else
      @comments = @comments.includes(post: :media_asset)
    end

    respond_with(@comments)
  end
end
