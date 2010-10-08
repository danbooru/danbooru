class ArtistVersionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @artist = Artist.find(params[:artist_id])
    @artist_versions = ArtistVersion.paginate :order => "version desc", :per_page => 25, :page => params[:page], :conditions => ["artist_id = ?", @artist.id]
    respond_with(@artist_versions)
  end
end
