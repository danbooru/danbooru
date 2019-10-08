class ArtistVersionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @artist_versions = ArtistVersion.includes(:updater).paginated_search(params)
    respond_with(@artist_versions)
  end

end
