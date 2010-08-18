class ArtistsController < ApplicationController
  def new
    @artist = Artist.new_with_defaults(params)
  end
  
  def edit
    @artist = Artist.find(params[:id])
  end
  
  def index
    order = params[:order] == "date" ? "updated_at DESC" : "name"
    limit = params[:limit] || 50
    @artists = Artist.paginate(Artist.build_relation())
  end
  
  def show
  end
  
  def create
  end
  
  def update
  end
  
  def destroy
  end

  def revert
  end
end
