class ModqueueController < ApplicationController
  respond_to :html, :json, :xml
  layout "sidebar"

  def index
    authorize :modqueue
    @posts = Post.includes(:appeals, :disapprovals, :uploader, flags: [:creator]).pending_or_flagged.available_for_moderation(search_params[:hidden])
    @posts = @posts.paginated_search(params, order: "modqueue", count_pages: true)

    @modqueue_posts = @posts.except(:offset, :limit, :order)
    @pending_post_count = @modqueue_posts.pending.count
    @flagged_post_count = @modqueue_posts.flagged.count
    @disapproval_reasons = PostDisapproval.where(post: @modqueue_posts).where.not(reason: "disinterest").group(:reason).order(count: :desc).distinct.count(:post_id)
    @uploaders = @modqueue_posts.group(:uploader).order(count: :desc).limit(20).count

    @tags = RelatedTagCalculator.frequent_tags_for_post_relation(@modqueue_posts)
    @artist_tags = @tags.select { |tag| tag.category == Tag.categories.artist }.sort_by(&:overlap_count).reverse.take(10)
    @copyright_tags = @tags.select { |tag| tag.category == Tag.categories.copyright }.sort_by(&:overlap_count).reverse.take(10)
    @character_tags = @tags.select { |tag| tag.category == Tag.categories.character }.sort_by(&:overlap_count).reverse.take(10)

    respond_with(@posts)
  end
end
