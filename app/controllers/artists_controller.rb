class ArtistsController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_action :member_only, :except => [:index, :show, :show_or_new, :banned]
  before_action :admin_only, :only => [:ban, :unban]
  before_action :load_artist, :only => [:ban, :unban, :show, :edit, :update, :destroy, :undelete]

  def new
    @artist = Artist.new_with_defaults(artist_params(:new))
    @artist.build_wiki_page if @artist.wiki_page.nil?
    respond_with(@artist)
  end

  def edit
    @artist.build_wiki_page if @artist.wiki_page.nil?
    respond_with(@artist)
  end

  def banned
    redirect_to artists_path(search: { is_banned: "true", order: "updated_at" }, format: request.format.symbol)
  end

  def ban
    @artist.ban!(banner: CurrentUser.user)
    redirect_to(artist_path(@artist), :notice => "Artist was banned")
  end

  def unban
    @artist.unban!
    redirect_to(artist_path(@artist), :notice => "Artist was unbanned")
  end

  def index
    # XXX
    params[:search][:name] = params.delete(:name) if params[:name]
    @artists = Artist.paginated_search(params)
    @artists = @artists.includes(:urls, :tag) if request.format.html?

    respond_with(@artists)
  end

  def show
    @artist = Artist.find(params[:id])
    respond_with(@artist)
  end

  def create
    @artist = Artist.create(artist_params)
    respond_with(@artist)
  end

  def update
    if params[:artist][:wiki_page_attributes] && params[:artist][:wiki_page_attributes][:id] && params[:artist][:name] && params[:artist][:name] != @artist.name
      if params[:artist][:rename_wiki].to_s.truthy?
        @wiki_page = WikiPage.find(params[:artist][:wiki_page_attributes][:id])
        @wiki_page.update(wiki_params)
      end
      params[:artist] = params[:artist].except(:wiki_page_attributes)
    end
    @artist.update(artist_params)
    flash[:notice] = @artist.valid? ? "Artist updated" : @artist.errors.full_messages.join("; ")
    respond_with(@artist)
  end

  def destroy
    @artist.update_attribute(:is_deleted, true)
    redirect_to(artist_path(@artist), :notice => "Artist deleted")
  end

  def revert
    @artist = Artist.find(params[:id])
    @version = @artist.versions.find(params[:version_id])
    @artist.revert_to!(@version)
    respond_with(@artist)
  end

  def show_or_new
    @artist = Artist.find_by_name(params[:name])

    if params[:name].blank?
      redirect_to new_artist_path(artist_params(:new))
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

  def load_artist
    @artist = Artist.find(params[:id])
  end

  def artist_params(context = nil)
    params[:artist] = params[:artist].except(:rename_wiki)
    permitted_params = %i[name other_names other_names_string group_name url_string notes is_deleted]
    permitted_params << { wiki_page_attributes: %i[id body] }
    permitted_params << :source if context == :new

    params.fetch(:artist, {}).permit(permitted_params)
  end

  def wiki_params
    permitted_params = %i[title body]
    sub_params = params[:artist][:wiki_page_attributes].except(:id)
    sub_params[:title] = params[:artist][:name]
    sub_params.permit(permitted_params)
  end
end
