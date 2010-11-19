class ArtistVersionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @search = Artist.search(params[:search])
    @artist_versions = @search.paginate :order => "version desc", :per_page => 25, :page => params[:page]
    respond_with(@artist_versions)
  end
end
