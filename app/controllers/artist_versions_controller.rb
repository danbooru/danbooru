class ArtistVersionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    set_version_comparison
    @artist_versions = ArtistVersion.paginated_search(params)
    @artist_versions = @artist_versions.includes(:updater, artist: :urls) if request.format.html?

    respond_with(@artist_versions)
  end

  def show
    @artist_version = ArtistVersion.find(params[:id])
    respond_with(@artist_version) do |format|
      format.html { redirect_to artist_versions_path(search: { artist_id: @artist_version.artist_id }) }
    end
  end
end
