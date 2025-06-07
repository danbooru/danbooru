# frozen_string_literal: true

class ArtistURLsController < ApplicationController
  respond_to :js, :json, :xml, :html

  def index
    @artist_urls = authorize ArtistURL.paginated_search(params)
    @artist_urls = @artist_urls.includes(:artist) if request.format.html?

    respond_with(@artist_urls)
  end
end
