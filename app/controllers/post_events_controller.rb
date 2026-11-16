# frozen_string_literal: true

class PostEventsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    if (post_id = params[:post_id] || params.dig(:search, :post_id))
      @post = Post.find(post_id)
    end

    @post_events = authorize PostEvent.paginated_search(params, defaults: { post_id: @post&.id }, count_pages: @post.present?)
    if request.format.html?
      @post_events = @post_events.includes(:creator, :post, model: [:post, :media_asset, :old_media_asset])
    else
      @post_events = @post_events.includes(model: :post)
    end

    respond_with(@post_events)
  end
end
