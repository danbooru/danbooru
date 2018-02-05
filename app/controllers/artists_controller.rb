class ArtistsController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :member_only, :except => [:index, :show, :show_or_new, :banned]
  before_filter :builder_only, :only => [:destroy]
  before_filter :admin_only, :only => [:ban, :unban]
  before_filter :load_artist, :only => [:ban, :unban, :show, :edit, :update, :destroy, :undelete]

  def new
    @artist = Artist.new_with_defaults(params)
    respond_with(@artist)
  end

  def edit
    respond_with(@artist)
  end

  def banned
    @artists = Artist.where("is_banned = ?", true).order("name")
    respond_with(@artists) do |format|
      format.xml do
        render :xml => @artists.to_xml(:include => [:urls], :root => "artists")
      end
      format.json do
        render :json => @artists.to_json(:include => [:urls])
      end
    end
  end

  def ban
    @artist.ban!
    redirect_to(artist_path(@artist), :notice => "Artist was banned")
  end

  def unban
    @artist.unban!
    redirect_to(artist_path(@artist), :notice => "Artist was unbanned")
  end

  def index
    search_params = params[:search].present? ? params[:search] : params
    @artists = Artist.includes(:urls).search(search_params).paginate(params[:page], :limit => params[:limit], :search_count => params[:search])
    respond_with(@artists) do |format|
      format.xml do
        render :xml => @artists.to_xml(:include => [:urls], :root => "artists")
      end
      format.json do
        render :json => @artists.to_json(:include => [:urls])
      end
    end
  end

  def show
    @artist = Artist.find(params[:id])
    @post_set = PostSets::Artist.new(@artist)
    respond_with(@artist, methods: [:domains], include: [:urls])
  end

  def create
    @artist = Artist.create(artist_params)
    respond_with(@artist)
  end

  def update
    @artist.update(artist_params)
    flash[:notice] = @artist.valid? ? "Artist updated" : @artist.errors.full_messages.join("; ")
    respond_with(@artist)
  end

  def destroy
    if !@artist.deletable_by?(CurrentUser.user)
      raise User::PrivilegeError
    end
    @artist.update_attribute(:is_active, false)
    redirect_to(artist_path(@artist), :notice => "Artist deleted")
  end

  def undelete
    if !@artist.deletable_by?(CurrentUser.user)
      raise User::PrivilegeError
    end
    @artist.update_attribute(:is_active, true)
    redirect_to(artist_path(@artist), :notice => "Artist undeleted")
  end

  def revert
    @artist = Artist.find(params[:id])
    @version = @artist.versions.find(params[:version_id])
    @artist.revert_to!(@version)
    respond_with(@artist)
  end

  def show_or_new
    @artist = Artist.find_by_name(params[:name])
    if @artist
      redirect_to artist_path(@artist)
    else
      @artist = Artist.new(name: params[:name])
      @post_set = PostSets::Artist.new(@artist)
      respond_with(@artist)
    end
  end

  def finder
    @artists = Artist.find_artists(params[:url], params[:referer_url])

    respond_with(@artists) do |format|
      format.xml do
        render :xml => @artists.to_xml(:include => [:sorted_urls], :root => "artists")
      end
      format.json do
        render :json => @artists.to_json(:include => [:sorted_urls])
      end
    end
  end

private

  def load_artist
    @artist = Artist.find(params[:id])
  end

  def artist_params
    permitted_params = %i[name other_names other_names_comma group_name url_string notes]
    permitted_params << :is_active if CurrentUser.is_builder?

    params.require(:artist).permit(permitted_params)
  end
end
