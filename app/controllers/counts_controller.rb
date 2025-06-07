# frozen_string_literal: true

class CountsController < ApplicationController
  respond_to :html, :xml, :json

  def posts
    estimate_count = params.fetch(:estimate_count, "true").truthy?
    skip_cache = params.fetch(:skip_cache, "false").truthy?
    @count = PostQuery.normalize(params[:tags], current_user: CurrentUser.user, tag_limit: CurrentUser.user.tag_query_limit).fast_count(timeout: CurrentUser.statement_timeout, estimate_count: estimate_count, skip_cache: skip_cache)
    skip_authorization

    if request.format.xml?
      respond_with({ posts: @count }, root: "counts")
    else
      respond_with({ counts: { posts: @count }})
    end
  end
end
