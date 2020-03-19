class ArtistCommentariesController < ApplicationController
  respond_to :html, :xml, :json, :js

  def index
    @commentaries = authorize ArtistCommentary.paginated_search(params)
    @commentaries = @commentaries.includes(post: :uploader) if request.format.html?

    respond_with(@commentaries)
  end

  def search
  end

  def show
    if params[:id]
      @commentary = authorize ArtistCommentary.find(params[:id])
    else
      @commentary = authorize ArtistCommentary.find_by_post_id!(params[:post_id])
    end

    respond_with(@commentary) do |format|
      format.html { redirect_to post_path(@commentary.post) }
    end
  end

  def create_or_update
    post_id = params[:artist_commentary].delete(:post_id)
    @artist_commentary = authorize ArtistCommentary.find_or_initialize_by(post_id: post_id)
    @artist_commentary.update(permitted_attributes(@artist_commentary))
    respond_with(@artist_commentary)
  end

  def revert
    @artist_commentary = authorize ArtistCommentary.find_by_post_id!(params[:id])
    @version = @artist_commentary.versions.find(params[:version_id])
    @artist_commentary.revert_to!(@version)
    respond_with(@artist_commentary)
  end
end
