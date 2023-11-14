# frozen_string_literal: true

class PostEventsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    if post_id = params[:post_id] || params.dig(:search, :post_id)
      @post = Post.find(post_id)
    end

    @post_events = authorize PostEvent.paginated_search(params, defaults: { post_id: @post&.id }, count_pages: @post.present?)
    @post_events = @post_events.includes(:creator, :post, model: [:post, :media_asset, :old_media_asset]) if request.format.html?

    respond_with(@post_events)
  end
end
