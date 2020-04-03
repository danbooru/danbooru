class BansController < ApplicationController
  respond_to :html, :xml, :json

  def new
    @ban = authorize Ban.new(permitted_attributes(Ban))
    respond_with(@ban)
  end

  def edit
    @ban = authorize Ban.find(params[:id])
    respond_with(@ban)
  end

  def index
    @bans = authorize Ban.paginated_search(params, count_pages: true)
    @bans = @bans.includes(:user, :banner) if request.format.html?

    respond_with(@bans)
  end

  def show
    @ban = authorize Ban.find(params[:id])
    respond_with(@ban)
  end

  def create
    @ban = authorize Ban.new(banner: CurrentUser.user, **permitted_attributes(Ban))
    @ban.save
    respond_with(@ban, location: bans_path)
  end

  def update
    @ban = authorize Ban.find(params[:id])
    @ban.update(permitted_attributes(@ban))
    respond_with(@ban)
  end

  def destroy
    @ban = authorize Ban.find(params[:id])
    @ban.destroy
    respond_with(@ban)
  end
end
