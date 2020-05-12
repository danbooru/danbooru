class ArtistsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def new
    @artist = authorize Artist.new_with_defaults(permitted_attributes(Artist))
    respond_with(@artist)
  end

  def edit
    @artist = authorize Artist.find(params[:id])
    respond_with(@artist)
  end

  def banned
    redirect_to artists_path(search: { is_banned: "true", order: "updated_at" }, format: request.format.symbol)
  end

  def ban
    @artist = authorize Artist.find(params[:id])
    @artist.ban!(banner: CurrentUser.user)
    redirect_to(artist_path(@artist), :notice => "Artist was banned")
  end

  def unban
    @artist = authorize Artist.find(params[:id])
    @artist.unban!
    redirect_to(artist_path(@artist), :notice => "Artist was unbanned")
  end

  def index
    # XXX
    params[:search][:name] = params.delete(:name) if params[:name]
    @artists = authorize Artist.paginated_search(params)
    @artists = @artists.includes(:urls, :tag) if request.format.html?

    respond_with(@artists)
  end

  def show
    @artist = authorize Artist.find(params[:id])
    respond_with(@artist)
  end

  def create
    @artist = authorize Artist.new(permitted_attributes(Artist))
    @artist.save
    respond_with(@artist)
  end

  def update
    @artist = authorize Artist.find(params[:id])
    @artist.update(permitted_attributes(@artist))
    flash[:notice] = @artist.valid? ? "Artist updated" : @artist.errors.full_messages.join("; ")
    respond_with(@artist)
  end

  def destroy
    @artist = authorize Artist.find(params[:id])
    @artist.update_attribute(:is_deleted, true)
    redirect_to(artist_path(@artist), :notice => "Artist deleted")
  end

  def revert
    @artist = authorize Artist.find(params[:id])
    @version = @artist.versions.find(params[:version_id])
    @artist.revert_to!(@version)
    respond_with(@artist)
  end

  def show_or_new
    @artist = Artist.find_by_name(params[:name])

    if params[:name].blank?
      redirect_to new_artist_path(permitted_attributes(Artist))
    elsif @artist.present?
      redirect_to artist_path(@artist)
    else
      @artist = Artist.new(name: params[:name])
      respond_with(@artist)
    end
  end

  private

  def item_matches_params(artist)
    if params[:search][:any_name_or_url_matches]
      artist.name == Artist.normalize_name(params[:search][:any_name_or_url_matches])
    else
      true
    end
  end
end
