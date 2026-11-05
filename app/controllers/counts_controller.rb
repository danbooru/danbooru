# frozen_string_literal: true

class CountsController < ApplicationController
  respond_to :html, :xml, :json

  def posts
    post_query = PostQuery.normalize(params[:tags], current_user: CurrentUser.user, tag_limit: CurrentUser.user.tag_query_limit)
    authorize post_query, policy_class: PostQueryPolicy
    post_query.validate_tag_limit!

    can_use_exact_counts = policy(post_query).can_use_exact_counts?
    estimate_count = !can_use_exact_counts || params.fetch(:estimate_count, "true").truthy?
    skip_cache = can_use_exact_counts && params.fetch(:skip_cache, "false").truthy?
    @count = post_query.fast_count(timeout: CurrentUser.statement_timeout, estimate_count: estimate_count, skip_cache: skip_cache)

    if request.format.xml?
      respond_with({ posts: @count }, root: "counts")
    else
      respond_with({ counts: { posts: @count }})
    end
  end
end
