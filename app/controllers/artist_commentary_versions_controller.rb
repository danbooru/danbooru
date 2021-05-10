class ArtistCommentaryVersionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    set_version_comparison
    @commentary_versions = ArtistCommentaryVersion.paginated_search(params)
    @commentary_versions = @commentary_versions.includes(:updater, post: :uploader) if request.format.html?

    respond_with(@commentary_versions)
  end

  def show
    @commentary_version = ArtistCommentaryVersion.find(params[:id])
    respond_with(@commentary_version) do |format|
      format.html { redirect_to artist_commentary_versions_path(search: { post_id: @commentary_version.post_id }) }
    end
  end
end
