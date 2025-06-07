# frozen_string_literal: true

class AutocompleteController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @query = params.dig(:search, :query)
    @type = params.dig(:search, :type)
    @limit = params.fetch(:limit, 10).to_i
    @autocomplete = authorize AutocompleteService.new(@query, @type, current_user: CurrentUser.user, limit: @limit)

    @results = @autocomplete.autocomplete_results
    @expires_in = @autocomplete.cache_duration
    @stale_while_revalidate = @autocomplete.stale_while_revalidate_duration
    @public = @autocomplete.cache_publicly?

    expires_in @expires_in, stale_while_revalidate: @stale_while_revalidate, public: @public unless response.cache_control.present?
    respond_with(@results, layout: false)
  end
end
