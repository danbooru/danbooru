class ArtistCommentaryVersionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @commentary_versions = ArtistCommentaryVersion.paginated_search(params)
    respond_with(@commentary_versions)
  end
end
