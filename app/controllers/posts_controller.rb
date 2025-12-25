# frozen_string_literal: true

class PostsController < ApplicationController
  respond_to :html, :xml, :json, :js
  layout "sidebar"

  before_action :log_search_query, only: :index
  after_action :log_search_count, only: :index, if: -> { request.format.html? && response.successful? }

  def index
    if params[:md5].present?
      @post = authorize Post.find_by!(md5: params[:md5])
      respond_with(@post) do |format|
        format.html { redirect_to(@post) }
      end
    elsif params[:random].to_s.truthy?
      query = "#{post_set.normalized_query.to_s} random:#{post_set.per_page}".strip
      authorize Post
      redirect_to posts_path(tags: query, page: params[:page], limit: params[:limit], format: request.format.symbol)
    else
      @posts = authorize post_set.posts, policy_class: PostPolicy
      @preview_size = params[:size].presence || cookies[:post_preview_size].presence || PostGalleryComponent::DEFAULT_SIZE
      raise PageRemovedError if request.format.html? && post_set.banned_artist?

      respond_with(@posts) do |format|
        format.atom
      end
    end
  end

  def show
    @post = authorize Post.eager_load(:uploader, :media_asset).find(params[:id])
    raise PageRemovedError if request.format.html? && @post.banblocked?(CurrentUser.user)

    if request.format.html?
      include_deleted = @post.is_deleted? || (@post.parent_id.present? && @post.parent.is_deleted?) || CurrentUser.user.show_deleted_children?
      @sibling_posts = @post.parent.present? ? @post.parent.children : Post.none
      @sibling_posts = @sibling_posts.undeleted unless include_deleted
      @sibling_posts = @sibling_posts.includes(:media_asset)

      @child_posts = @post.children
      @child_posts = @child_posts.undeleted unless include_deleted
      @sibling_posts = @sibling_posts.includes(:media_asset)
    end

    respond_with(@post) do |format|
      format.html.tooltip { render layout: false }
    end
  end

  def show_seq
    authorize Post
    context = PostSearchContext.new(params)
    if context.post_id
      redirect_to(post_path(context.post_id, q: params[:q]))
    else
      redirect_to(post_path(params[:id], q: params[:q]))
    end
  end

  def update
    @post = authorize Post.find(params[:id])
    @post.update(permitted_attributes(@post))
    @show_votes = (params[:show_votes].presence || cookies[:post_preview_show_votes].presence || "false").truthy?
    @preview_size = params[:size].presence || cookies[:post_preview_size].presence || PostGalleryComponent::DEFAULT_SIZE
    respond_with_post_after_update(@post)
  end

  def create
    @upload_media_asset = UploadMediaAsset.find(params[:upload_media_asset_id])
    @post = authorize Post.new_from_upload(@upload_media_asset, **permitted_attributes(Post).to_h.symbolize_keys)
    @post.save_if_unique(:md5)

    if @post.errors.none?
      notice = @post.warnings.full_messages.join(".\n \n") if @post.warnings.any?
      respond_with(@post, notice: notice)
    elsif @post.errors.of_kind?(:md5, :taken)
      @original_post = Post.find_by!(md5: @post.md5)
      @original_post.update(rating: @post.rating, parent_id: @post.parent_id, tag_string: "#{@original_post.tag_string} #{@post.tag_string}")
      flash[:notice] = "Duplicate of post ##{@original_post.id}; merging tags"
      redirect_to @original_post
    else
      @post.tag_string = params.dig(:post, :tag_string) # Preserve original tag string on validation error
      respond_with(@post, render: { template: "upload_media_assets/show" })
    end
  end

  def destroy
    @post = authorize Post.find(params[:id])

    if params[:commit] == "Delete"
      move_favorites = params.dig(:post, :move_favorites).to_s.truthy?
      @post.delete!(params.dig(:post, :reason), move_favorites: move_favorites, user: CurrentUser.user)
      flash[:notice] = "Post deleted"
    end

    respond_with_post_after_update(@post)
  end

  def revert
    @post = authorize Post.find(params[:id])
    @version = @post.versions.find(params[:version_id])
    @post.revert_to!(@version)

    respond_with(@post) do |format|
      format.js
    end
  end

  def copy_notes
    @post = Post.find(params[:id])
    @other_post = authorize Post.find(params[:other_post_id].to_i)
    @post.copy_notes_to(@other_post)

    if @post.errors.any?
      @error_message = @post.errors.full_messages.join("; ")
      render :json => {:success => false, :reason => @error_message}.to_json, :status => 400
    else
      head 204
    end
  end

  def random
    @post = Post.user_tag_match(params[:tags]).random(1).take
    authorize @post, policy_class: PostPolicy

    raise ActiveRecord::RecordNotFound if @post.nil?
    respond_with(@post) do |format|
      format.html { redirect_to post_path(@post, q: params[:tags]) }
    end
  end

  def mark_as_translated
    @post = authorize Post.find(params[:id])
    @post.mark_as_translated(params[:post])
    respond_with_post_after_update(@post)
  end

  private

  def post_set
    @post_set ||= begin
      tag_query = params[:tags] || params.dig(:post, :tags)
      show_votes = (params[:show_votes].presence || cookies[:post_preview_show_votes].presence || "false").truthy?
      PostSets::Post.new(tag_query, params[:page], params[:limit], format: request.format.symbol, show_votes: show_votes)
    end
  end

  def log_search_query
    DanbooruLogger.add_attributes("search", {
      query: post_set.normalized_query.to_s,
      page: post_set.current_page,
      limit: post_set.per_page,
      tag_count: post_set.post_query.tag_names.length,
      metatag_count: post_set.post_query.metatags.length,
    })
  end

  def log_search_count
    DanbooruLogger.add_attributes("search", { count: post_set.post_count, })
  end

  def respond_with_post_after_update(post)
    respond_with(post) do |format|
      format.html do
        if post.warnings.any?
          flash[:notice] = post.warnings.full_messages.join(".\n \n")
        end

        if post.errors.any?
          flash[:notice] = post.errors.full_messages.join("; ")
        end

        redirect_to post_path(post, { q: params[:q] }.compact_blank)
      end

      format.json do
        render :json => post.to_json
      end
    end
  end
end
