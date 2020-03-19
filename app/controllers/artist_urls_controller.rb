class ArtistUrlsController < ApplicationController
  respond_to :js, :json, :xml, :html

  def index
    @artist_urls = ArtistUrl.paginated_search(params)
    @artist_urls = @artist_urls.includes(:artist) if request.format.html?

    respond_with(@artist_urls)
  end
end
