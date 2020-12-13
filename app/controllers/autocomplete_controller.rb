class AutocompleteController < ApplicationController
  respond_to :xml, :json

  def index
    @query = params.dig(:search, :query)
    @type = params.dig(:search, :type)
    @limit = params.fetch(:limit, 10).to_i
    @autocomplete = AutocompleteService.new(@query, @type, current_user: CurrentUser.user, limit: @limit)

    @results = @autocomplete.autocomplete_results
    respond_with(@results)
  end
end
