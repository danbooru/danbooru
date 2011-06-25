class ArtistsController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :member_only, :except => [:index, :show]
  
  def new
    @artist = Artist.new_with_defaults(params)
    respond_with(@artist)
  end
  
  def edit
    @artist = Artist.find(params[:id])
    respond_with(@artist)
  end
  
  def index
    @search = Artist.search(params[:search])
    @artists = @search.paginate(params[:page])
    respond_with(@artists)
  end
  
  def search
    @search = Artist.search(params[:search])
  end
  
  def show
    @artist = Artist.find(params[:id])
    
    if @artist
      @posts = Danbooru.config.select_posts_visible_to_user(CurrentUser.user, Post.tag_match(@artist.name).limit(6))
    end

    respond_with(@artist)
  end
  
  def create
    @artist = Artist.create(params[:artist])
    respond_with(@artist)
  end
  
  def update
    @artist = Artist.find(params[:id])
    @artist.update_attributes(params[:artist])
    respond_with(@artist)
  end
  
  def revert
    @artist = Artist.find(params[:id])
    @version = ArtistVersion.find(params[:version_id])
    @artist.revert_to!(@version)
    respond_with(@artist)
  end
end
