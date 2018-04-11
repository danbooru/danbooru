class ArtistCommentariesController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_action :member_only, :except => [:index, :show]

  def index
    @commentaries = ArtistCommentary.search(search_params).paginate(params[:page], :limit => params[:limit])
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
    @artist_commentary = ArtistCommentary.find_or_initialize_by(post_id: params.dig(:artist_commentary, :post_id))
    @artist_commentary.update(commentary_params)
    respond_with(@artist_commentary)
  end

  def revert
    @artist_commentary = ArtistCommentary.find_by_post_id!(params[:id])
    @version = @artist_commentary.versions.find(params[:version_id])
    @artist_commentary.revert_to!(@version)
  end

private

  def commentary_params
    params.fetch(:artist_commentary, {}).except(:post_id).permit(%i[
      original_description original_title translated_description translated_title
      remove_commentary_tag remove_commentary_request_tag remove_commentary_check_tag
      add_commentary_tag add_commentary_request_tag add_commentary_check_tag
    ])
  end
end
