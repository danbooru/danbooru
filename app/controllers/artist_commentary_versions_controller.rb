class ArtistCommentaryVersionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @commentary_versions = ArtistCommentaryVersion.search(search_params).paginate(params[:page], :limit => params[:limit])
    respond_with(@commentary_versions) do |format|
      format.xml do
        render :xml => @commentary_versions.to_xml(:root => "artist-commentary-versions")
      end
    end
  end
end
