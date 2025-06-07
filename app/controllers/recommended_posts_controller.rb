# frozen_string_literal: true

class RecommendedPostsController < ApplicationController
  respond_to :html, :json, :xml, :js

  after_action :skip_authorization

  def index
    limit = params.fetch(:limit, 100).to_i.clamp(0, 200)
    @recs = RecommenderService.search(search_params).take(limit)
    @posts = @recs.pluck(:post)

    respond_with(@recs)
  end
end
