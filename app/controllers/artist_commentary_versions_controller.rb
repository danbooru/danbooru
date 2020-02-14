class ArtistCommentaryVersionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @commentary_versions = ArtistCommentaryVersion.paginated_search(params).includes(model_includes(params))
    respond_with(@commentary_versions)
  end

  def show
    @commentary_version = ArtistCommentaryVersion.find(params[:id])
    respond_with(@commentary_version) do |format|
      format.html { redirect_to artist_commentary_versions_path(search: { post_id: @commentary_version.post_id }) }
    end
  end

  private

  def default_includes(params)
    if ["json", "xml"].include?(params[:format])
      []
    else
      [{post: [:uploader]}, :updater]
    end
  end
end
