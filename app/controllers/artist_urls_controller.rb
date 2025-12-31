# frozen_string_literal: true

class ArtistURLsController < ApplicationController
  respond_to :js, :json, :xml, :html

  def index
    params[:search][:artist_id] = params[:artist_id]
    @artist_urls = authorize ArtistURL.paginated_search(params)
    @artist_urls = @artist_urls.includes(:artist) if request.format.html?

    respond_with(@artist_urls)
  end

  def show
    @artist_url = authorize ArtistURL.find(params[:id])
    respond_with(@artist_url) do |format|
      format.html { redirect_to artist_urls_path(search: { id: @artist_url.id }) }
    end
  end

  def create
    artist_id = params[:artist_url].delete(:artist_id) || params[:artist_id]
    @artist = Artist.find(artist_id)
    
    attrs = permitted_attributes(ArtistURL)
    @artist_url = @artist.urls.find_or_initialize_by(url: attrs[:url])
    status = @artist_url.new_record? ? :created : :ok
    @artist_url.attributes = attrs
    authorize @artist_url
    @artist_url.save

    respond_with(@artist, @artist_url, status: status)
  end

  def update
    @artist_url = authorize ArtistURL.find(params[:id])
    @artist = @artist_url.artist
    @artist_url.update(permitted_attributes(@artist_url))
    respond_with(@artist_url)
  end

  def destroy
    @artist_url = authorize ArtistURL.find(params[:id])
    @artist = @artist_url.artist
    @artist_url.destroy
    respond_with(@artist_url)
  end
end
