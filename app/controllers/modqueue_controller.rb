class ModqueueController < ApplicationController
  respond_to :html, :json, :xml
  before_action :approver_only

  def index
    @posts = Post.includes(:appeals, :disapprovals, :uploader, flags: [:creator]).reorder(id: :asc).pending_or_flagged.available_for_moderation(search_params[:hidden]).tag_match(search_params[:tags]).paginated_search(params, count_pages: true)
    respond_with(@posts)
  end
end
