# frozen_string_literal: true

class RateLimitsController < ApplicationController
  respond_to :html, :json, :xml

  def index
    @rate_limits = authorize RateLimit.visible(CurrentUser.user).paginated_search(params, count_pages: true)
    respond_with(@rate_limits)
  end
end
