class ArtistVersionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @artist_versions = ArtistVersion.search(params[:search]).paginate(params[:page])
    respond_with(@artist_versions)
  end
end
