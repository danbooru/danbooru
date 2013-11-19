class ArtistCommentariesController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_filter :member_only

  def create_or_update
    @artist_commentary = ArtistCommentary.find_by_post_id(params[:artist_commentary][:post_id])

    if @artist_commentary
      @artist_commentary.update_attributes(params[:artist_commentary])
    else
      @artist_commentary = ArtistCommentary.create(params[:artist_commentary])
    end

    respond_with(@artist_commentary.post)
  end

  def revert
    @artist_commentary = ArtistCommentary.find_by_post_id(params[:id])
    @version = ArtistCommentaryVersion.find(params[:version_id])
    @artist_commentary.revert_to!(@version)
    respond_with(@artist_commentary)
  end
end
