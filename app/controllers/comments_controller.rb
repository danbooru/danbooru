# frozen_string_literal: true

class CommentsController < ApplicationController
  respond_to :html, :xml, :json, :atom
  respond_to :js, only: [:new, :update, :destroy, :undelete]

  before_action if: -> { request.format.html? && !Danbooru.config.comments_enabled?.to_s.truthy? } do
    redirect_to root_path
  end

  def index
    params[:group_by] ||= "comment" if params[:search].present?

    if params[:group_by] == "comment" || request.format.atom?
      index_by_comment
    elsif request.format.js?
      index_for_post
    else
      index_by_post
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

  def update
    @comment = Comment.find(params[:id])
    @comment.attributes = { updater: CurrentUser.user, **permitted_attributes(@comment) }
    authorize(@comment).save

    respond_with(@comment)
  end

  def create
    @comment = authorize Comment.new(creator: CurrentUser.user, creator_ip_addr: request.remote_ip, **permitted_attributes(Comment))
    @comment.save

    respond_with(@comment, notice: "Comment posted") do |format|
      format.html do
        redirect_back fallback_location: (@comment.post || comments_path)
      end
    end
  end

  def edit
    @comment = authorize Comment.find(params[:id])
    respond_with(@comment)
  end

  def show
    @comment = authorize Comment.find(params[:id])

    respond_with(@comment) do |format|
      format.html do
        redirect_to post_path(@comment.post, anchor: "comment_#{@comment.id}")
      end
    end
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
    @post = Post.find(params[:post_id])
    @comments = authorize @post.comments
    render :action => "index_for_post"
  end

  def index_by_post
    @limit = params.fetch(:limit, 20)
    @posts = Post.where.not(last_comment_bumped_at: nil).user_tag_match(params[:tags]).reorder("last_comment_bumped_at DESC NULLS LAST").paginate(params[:page], limit: @limit, search_count: params[:search])
    authorize @posts

    respond_with(@posts)
  end

  def index_by_comment
    @comments = authorize Comment.paginated_search(params)

    if request.format.atom?
      @comments = @comments.includes(:creator, post: [:media_asset])
      @comments = @comments.select { |comment| comment.post.visible? }
    elsif request.format.html?
      @comments = @comments.includes(:creator, :updater, post: [:uploader, :media_asset])
      @comments = @comments.includes(:votes) if CurrentUser.is_member?
    end

    respond_with(@comments)
  end
end
