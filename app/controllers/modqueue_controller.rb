class ModqueueController < ApplicationController
  respond_to :html, :json, :xml
  before_action :approver_only
  layout "sidebar"

  def index
    @posts = Post.includes(:appeals, :disapprovals, :uploader, flags: [:creator]).pending_or_flagged.available_for_moderation(search_params[:hidden]).tag_match(search_params[:tags])

    @pending_post_count = @posts.pending.count
    @flagged_post_count = @posts.flagged.count
    @disapproval_reasons = PostDisapproval.where(post: @posts).where.not(reason: "disinterest").group(:reason).order(count: :desc).distinct.count(:post_id)
    @uploaders = @posts.reorder(nil).group(:uploader).order(count: :desc).limit(20).count

    @tags = RelatedTagCalculator.frequent_tags_for_post_relation(@posts)
    @artist_tags = @tags.select { |tag| tag.category == Tag.categories.artist }.sort_by(&:overlap_count).reverse.take(10)
    @copyright_tags = @tags.select { |tag| tag.category == Tag.categories.copyright }.sort_by(&:overlap_count).reverse.take(10)
    @character_tags = @tags.select { |tag| tag.category == Tag.categories.character }.sort_by(&:overlap_count).reverse.take(10)

    @posts = @posts.reorder(id: :asc).paginated_search(params, count_pages: true)
    respond_with(@posts)
  end
end
