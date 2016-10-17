class BansController < ApplicationController
  before_filter :moderator_only, :except => [:show, :index]
  respond_to :html, :xml, :json

  def new
    @ban = Ban.new(params[:ban])
  end

  def edit
    @ban = Ban.find(params[:id])
  end

  def index
    @search = Ban.search(params[:search]).order("id desc")
    @bans = @search.paginate(params[:page], :limit => params[:limit])
    respond_with(@bans)
  end

  def show
    @ban = Ban.find(params[:id])
    respond_with(@ban)
  end

  def create
    @ban = Ban.create(params[:ban])

    if @ban.errors.any?
      render :action => "new"
    else
      redirect_to ban_path(@ban), :notice => "Ban created"
    end
  end

  def update
    @ban = Ban.find(params[:id])
    if @ban.update_attributes(params[:ban])
      redirect_to ban_path(@ban), :notice => "Ban updated"
    else
      render :action => "edit"
    end
  end

  def destroy
    @ban = Ban.find(params[:id])
    @ban.destroy
    redirect_to bans_path, :notice => "Ban destroyed"
  end
end
