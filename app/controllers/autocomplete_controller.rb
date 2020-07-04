class AutocompleteController < ApplicationController
  respond_to :xml, :json

  def index
    @tags = Tag.names_matches_with_aliases(params[:query], params.fetch(:limit, 10).to_i)

    if request.variant.opensearch?
      expires_in 1.hour
      results = [params[:query], @tags.map(&:pretty_name)]
      respond_with(results)
    else
      # XXX
      respond_with(@tags.map(&:attributes))
    end
  end
end
