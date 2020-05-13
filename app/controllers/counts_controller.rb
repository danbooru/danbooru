class CountsController < ApplicationController
  respond_to :xml, :json

  def posts
    estimate_count = params.fetch(:estimate_count, "true").truthy?
    skip_cache = params.fetch(:skip_cache, "false").truthy?
    @count = PostQueryBuilder.new(params[:tags], CurrentUser.user).normalized_query.fast_count(timeout: CurrentUser.statement_timeout, estimate_count: estimate_count, skip_cache: skip_cache)
  end
end
