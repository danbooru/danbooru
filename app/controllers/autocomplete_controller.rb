class AutocompleteController < ApplicationController
  respond_to :xml, :json

  def index
    @query = params.dig(:search, :query)
    @type = params.dig(:search, :type)
    @limit = params.fetch(:limit, 10).to_i
    @autocomplete = AutocompleteService.new(@query, @type, current_user: CurrentUser.user, limit: @limit)

    @results = @autocomplete.autocomplete_results
    @expires_in = @autocomplete.cache_duration
    @public = @autocomplete.cache_publicly?

    expires_in @expires_in, public: @public unless response.cache_control.present?
    respond_with(@results)
  end
end
