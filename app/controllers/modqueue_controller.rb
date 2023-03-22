# frozen_string_literal: true

class ModqueueController < ApplicationController
  respond_to :html, :json, :xml
  layout "sidebar"

  def index
    authorize :modqueue
    @mode = params.fetch(:mode, "gallery")
    @limit = params.fetch(:limit, CurrentUser.user.per_page).to_i.clamp(0, PostSets::Post::MAX_PER_PAGE)

    @posts = Post.includes(:appeals, :vote_by_current_user, :uploader, :media_asset, disapprovals: [:user], flags: [:creator])
    @posts = @posts.available_for_moderation(CurrentUser.user, search_params.fetch(:modqueue, :unseen))
    @posts = @posts.paginated_search(params, limit: @limit, count_pages: true, defaults: { order: "modqueue" })
    @modqueue_posts = @posts.distinct.except(:select, :group, :order, :offset, :limit)

    @pending_post_count = @modqueue_posts.select(&:is_pending?).count
    @flagged_post_count = @modqueue_posts.select(&:is_flagged?).count
    @appealed_post_count = @modqueue_posts.select(&:is_appealed?).count
    @disapproval_reasons = PostDisapproval.where(post_id: @modqueue_posts.map(&:id)).where.not(reason: "disinterest").group(:reason).order(count: :desc).distinct.count(:post_id)
    @uploaders = @modqueue_posts.map(&:uploader).tally.sort_by(&:last).reverse.take(20).to_h

    #@new_count = @modqueue_posts.available_for_moderation(CurrentUser.user, search_params.fetch(:modqueue, :unseen)).count
    #@seen_count = @modqueue_posts.available_for_moderation(CurrentUser.user, search_params.fetch(:modqueue, :seen)).where(id: CurrentUser.user.post_disapprovals.select(:post_id)).count

    @tags = RelatedTagCalculator.new.frequent_tags_for_post_relation(@modqueue_posts, @modqueue_posts.size).map(&:tag)
    @artist_tags = @tags.select(&:artist?).sort_by(&:overlap_count).reverse.take(10)
    @copyright_tags = @tags.select(&:copyright?).sort_by(&:overlap_count).reverse.take(10)
    @character_tags = @tags.select(&:character?).sort_by(&:overlap_count).reverse.take(10)

    @preview_size = params[:size].presence || cookies[:post_preview_size].presence || PostPreviewComponent::DEFAULT_SIZE

    respond_with(@posts, model: "Post")
  end
end
