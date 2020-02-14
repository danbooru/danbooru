class ArtistUrlsController < ApplicationController
  respond_to :js, :json, :xml, :html
  before_action :member_only, except: [:index]

  def index
    @artist_urls = ArtistUrl.paginated_search(params).includes(model_includes(params))
    respond_with(@artist_urls) do |format|
      format.json { render json: @artist_urls.to_json(format_params) }
      format.xml { render xml: @artist_urls.to_xml(format_params) }
    end
  end

  def update
    @artist_url = ArtistUrl.find(params[:id])
    @artist_url.update(artist_url_params)
    respond_with(@artist_url)
  end

  private

  def default_includes(params)
    if ["json", "xml"].include?(params[:format])
      [{artist: [:urls]}]
    else
      [:artist]
    end
  end

  def format_params
    param_hash = {}
    if params[:only]
      param_hash[:only] = params[:only]
    else
      param_hash[:include] = [:artist]
    end
    if request.format.symbol == :xml
      param_hash[:root] = "artist-urls"
    end
    param_hash
  end

  def artist_url_params
    permitted_params = %i[is_active]

    params.fetch(:artist_url, {}).permit(permitted_params)
  end
end
