# frozen_string_literal: true

class RateLimitsController < ApplicationController
  respond_to :html, :json, :xml

  def index
    @rate_limits = authorize RateLimit.visible(CurrentUser.user).paginated_search(params, count_pages: true)

    # Several rows can share the same key and humanized action (e.g. separate
    # per-post buckets for "notes:write:post-1" and "notes:write:post-2" both
    # humanize to "Notes: write"). Collapse those to the most limited row so
    # the table doesn't show confusing, unexplained duplicates.
    @displayed_rate_limits = @rate_limits.group_by { |rate_limit| [rate_limit.key, rate_limit.humanized_action] }.map { |_, group| group.min_by(&:points) }

    respond_with(@rate_limits)
  end
end
