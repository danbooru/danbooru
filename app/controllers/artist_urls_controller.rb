class ArtistUrlsController < ApplicationController
  respond_to :json, :xml, :html
  before_action :member_only, except: [:index]

  def index
    @artist_urls = ArtistUrl.includes(:artist).search(search_params).paginate(params[:page], :limit => params[:limit], :search_count => params[:search])
    respond_with(@artist_urls) do |format|
      format.json { render json: @artist_urls.to_json(include: "artist",) }
      format.xml { render xml: @artist_urls.to_xml(include: "artist", root: "artist-urls") }
    end
  end

  def update
    @artist_url = ArtistUrl.find(params[:id])
    @artist_url.update(artist_url_params)
    respond_with(@artist_url)
  end

private

  def artist_url_params
    permitted_params = %i[is_active]

    params.fetch(:artist_url, {}).permit(permitted_params)
  end
end
