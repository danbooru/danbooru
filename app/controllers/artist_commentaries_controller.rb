class ArtistCommentariesController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_filter :member_only, :except => [:index, :show]

  def index
    @commentaries = ArtistCommentary.search(params[:search]).paginate(params[:page], :limit => params[:limit])
    respond_with(@commentaries) do |format|
      format.xml do
        render :xml => @commentaries.to_xml(:root => "artist-commentaries")
      end
    end
  end

  def show
    if params[:id]
      @commentary = ArtistCommentary.find(params[:id])
    else
      @commentary = ArtistCommentary.find_by_post_id!(params[:post_id])
    end

    respond_with(@commentary) do |format|
      format.html { redirect_to post_path(@commentary.post) }
    end
  end

  def create_or_update
    @artist_commentary = ArtistCommentary.find_by_post_id(params[:artist_commentary][:post_id])

    if @artist_commentary
      @artist_commentary.update_attributes(params[:artist_commentary])
    else
      @artist_commentary = ArtistCommentary.create(params[:artist_commentary])
    end

    respond_with(@artist_commentary)
  end

  def revert
    @artist_commentary = ArtistCommentary.find_by_post_id!(params[:id])
    @version = @artist_commentary.versions.find(params[:version_id])
    @artist_commentary.revert_to!(@version)
    respond_with(@artist_commentary)
  end
end
