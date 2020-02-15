class ArtistUrlsController < ApplicationController
  respond_to :js, :json, :xml, :html
  before_action :member_only, except: [:index]

  def index
    @artist_urls = ArtistUrl.paginated_search(params).includes(model_includes(params))
    respond_with(@artist_urls)
  end

  def update
    @artist_url = ArtistUrl.find(params[:id])
    @artist_url.update(artist_url_params)
    respond_with(@artist_url)
  end

  private

  def default_includes(params)
    if ["json", "xml"].include?(params[:format])
      []
    else
      [:artist]
    end
  end

  def artist_url_params
    permitted_params = %i[is_active]

    params.fetch(:artist_url, {}).permit(permitted_params)
  end
end
