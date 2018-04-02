class BansController < ApplicationController
  before_action :moderator_only, :except => [:show, :index]
  respond_to :html, :xml, :json
  helper_method :search_params

  def new
    @ban = Ban.new(params[:ban])
  end

  def edit
    @ban = Ban.find(params[:id])
  end

  def index
    @bans = Ban.search(search_params).paginate(params[:page], :limit => params[:limit])
    respond_with(@bans) do |fmt|
      fmt.html { @bans = @bans.includes(:user, :banner) }
    end
  end

  def show
    @ban = Ban.find(params[:id])
    respond_with(@ban)
  end

  def create
    @ban = Ban.create(ban_params(:create))

    if @ban.errors.any?
      render :action => "new"
    else
      redirect_to ban_path(@ban), :notice => "Ban created"
    end
  end

  def update
    @ban = Ban.find(params[:id])
    if @ban.update(ban_params(:update))
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

  private

  def ban_params(context)
    permitted_params = %i[reason duration expires_at]
    permitted_params += %i[user_id user_name] if context == :create

    params.require(:ban).permit(permitted_params)
  end
end
