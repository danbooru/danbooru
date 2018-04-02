class ArtistVersionsController < ApplicationController
  before_action :member_only
  respond_to :html, :xml, :json

  def index
    @artist_versions = ArtistVersion.search(search_params).paginate(params[:page], :limit => params[:limit], :search_count => params[:search])
    respond_with(@artist_versions) do |format|
      format.xml do
        render :xml => @artist_versions.to_xml(:root => "artist-versions")
      end
    end
  end

end
