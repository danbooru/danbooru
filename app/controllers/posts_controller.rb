# frozen_string_literal: true

class PostsController < ApplicationController
  respond_to :html, :xml, :json, :js
  layout "sidebar"

  before_action :log_search_query, only: :index
  after_action :log_search_count, only: :index, if: -> { request.format.html? && response.successful? }
  rate_limit :index, rate: 1.0/2.seconds, burst: 50, if: -> { request.format.atom? }, key: "posts:index.atom"

  def index
    if params[:md5].present?
      @post = authorize Post.find_by!(md5: params[:md5])
      respond_with(@post) do |format|
        format.html { redirect_to(@post) }
      end
    elsif params[:random].to_s.truthy?
      query = "#{post_set.normalized_query.to_s} random:#{post_set.per_page}".strip
      redirect_to posts_path(tags: query, page: params[:page], limit: params[:limit], format: request.format.symbol)
    else
      @preview_size = params[:size].presence || cookies[:post_preview_size].presence || PostGalleryComponent::DEFAULT_SIZE
      @posts = authorize post_set.posts, policy_class: PostPolicy
      respond_with(@posts) do |format|
        format.atom
      end
    end
  end

  def show
    @post = authorize Post.find(params[:id])

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
    @show_votes = (params[:show_votes].presence || cookies[:post_preview_show_votes].presence || "true").truthy?
    @preview_size = params[:size].presence || cookies[:post_preview_size].presence || PostGalleryComponent::DEFAULT_SIZE
    respond_with_post_after_update(@post)
  end

  def create
    @upload_media_asset = UploadMediaAsset.find(params[:upload_media_asset_id])
    @post = authorize Post.new_from_upload(@upload_media_asset, **permitted_attributes(Post).to_h.symbolize_keys)
    @post.save_if_unique(:md5)

    if @post.errors.none?
      if @post.warnings.any?
        flash[:notice] = @post.warnings.full_messages.join(".\n \n")
      end

      respond_with(@post)
    elsif @post.errors.of_kind?(:md5, :taken)
      @original_post = Post.find_by!(md5: @post.md5)
      @original_post.update(rating: @post.rating, parent_id: @post.parent_id, tag_string: "#{@original_post.tag_string} #{@post.tag_string}")
      flash[:notice] = "Duplicate of post ##{@original_post.id}; merging tags"
      redirect_to @original_post
    else
      flash[:notice] = @post.errors.full_messages.join("; ")
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
    raise ActiveRecord::RecordNotFound if @post.nil?
    authorize @post
    respond_with(@post) do |format|
      format.html { redirect_to post_path(@post, :tags => params[:tags]) }
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
      show_votes = (params[:show_votes].presence || cookies[:post_preview_show_votes].presence || "true").truthy?
      PostSets::Post.new(tag_query, params[:page], params[:limit], format: request.format.symbol, show_votes: show_votes)
    end
  end

  def log_search_query
    DanbooruLogger.add_attributes("search", {
      query: post_set.normalized_query.to_s,
      page: post_set.current_page,
      limit: post_set.per_page,
      term_count: post_set.normalized_query.terms.count,
      tag_count: post_set.normalized_query.tags.count,
      metatag_count: post_set.normalized_query.metatags.count,
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
          @error_message = post.errors.full_messages.join("; ")
          render :template => "static/error", :status => 500
        else
          response_params = {:q => params[:tags_query], :pool_id => params[:pool_id], :favgroup_id => params[:favgroup_id]}
          response_params.reject! {|_key, value| value.blank?}
          redirect_to post_path(post, response_params)
        end
      end

      format.json do
        render :json => post.to_json
      end
    end
  end
end
