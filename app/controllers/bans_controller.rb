class BansController < ApplicationController
  def new
    @ban = Ban.new
  end
  
  def edit
    @ban = Ban.find(params[:id])
  end
  
  def index
    @search = Ban.search(params[:search])
    @bans = @search.paginate(:page => params[:page])
  end
  
  def show
    @ban = Ban.find(params[:id])
  end
  
  def create
    @ban = Ban.new(params[:ban])
    if @ban.save
      redirect_to ban_path(@ban)
    else
      render :action => "new"
    end
  end
  
  def update
    @ban = Ban.find(params[:id])
    if @ban.update_attributes(params[:ban])
      redirect_to ban_path(@ban)
    else
      render :action => "edit"
    end
  end  
end
