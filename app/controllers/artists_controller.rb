class ArtistsController < ApplicationController
  before_filter :member_only
  
  def new
    @artist = Artist.new_with_defaults(params)
  end
  
  def edit
    @artist = Artist.find(params[:id])
  end
  
  def index
    @artists = Artist.build_relation(params).paginate(:per_page => 25, :page => params[:page])
  end
  
  def show
    @artist = Artist.find(params[:id])
    
    if @artist
      @posts = Danbooru.config.select_posts_visible_to_user(CurrentUser.user, Post.find_by_tags(@artist.name, :limit => 6))
    else
      redirect_to new_artist_path(params[:name])
    end
  end
  
  def create
    @artist = Artist.create(params[:artist])

    if @artist.errors.empty?
      redirect_to artist_path(@artist)
    else
      flash[:notice] = "There were errors"
      render :action => "new"
    end
  end
  
  def update
    @artist = Artist.find(params[:id])
    @artist.update_attributes(params[:artist])
    
    if @artist.errors.empty?
      redirect_to artist_path(@artist)
    else
      flash[:notice] = "There were errors"
      render :action => "edit"
    end
  end
  
  def revert
    @artist = Artist.find(params[:id])
    @artist.revert_to!(params[:version])
    redirect_to artist_path(@artist)
  end
end
