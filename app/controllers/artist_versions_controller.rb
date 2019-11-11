class ArtistVersionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @artist_versions = ArtistVersion.includes(:updater).paginated_search(params)
    respond_with(@artist_versions)
  end

  def show
    @artist_version = ArtistVersion.find(params[:id])
    respond_with(@artist_version) do |format|
      format.html { redirect_to artist_versions_path(search: { artist_id: @artist_version.artist_id }) }
    end
  end
end
