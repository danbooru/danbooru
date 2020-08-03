class ModqueueController < ApplicationController
  respond_to :html, :json, :xml
  layout "sidebar"

  def index
    authorize :modqueue
    @posts = Post.includes(:appeals, :disapprovals, :uploader, flags: [:creator]).in_modqueue.available_for_moderation(CurrentUser.user, hidden: search_params[:hidden])
    @posts = @posts.paginated_search(params, order: "modqueue", count_pages: true)

    @modqueue_posts = @posts.reselect(nil).reorder(nil).offset(nil).limit(nil)
    @pending_post_count = @modqueue_posts.select(&:is_pending?).count
    @flagged_post_count = @modqueue_posts.select(&:is_flagged?).count
    @disapproval_reasons = PostDisapproval.where(post: @modqueue_posts.reselect(:id)).where.not(reason: "disinterest").group(:reason).order(count: :desc).distinct.count(:post_id)
    @uploaders = @modqueue_posts.map(&:uploader).tally.sort_by(&:last).reverse.take(20).to_h

    @tags = RelatedTagCalculator.frequent_tags_for_post_relation(@modqueue_posts)
    @artist_tags = @tags.select(&:artist?).sort_by(&:overlap_count).reverse.take(10)
    @copyright_tags = @tags.select(&:copyright?).sort_by(&:overlap_count).reverse.take(10)
    @character_tags = @tags.select(&:character?).sort_by(&:overlap_count).reverse.take(10)

    respond_with(@posts)
  end
end
