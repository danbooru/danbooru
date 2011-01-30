class ArtistVersionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @search = ArtistVersion.search(params[:search])
    @artist_versions = @search.paginate :page => params[:page]
    respond_with(@artist_versions)
  end
end
