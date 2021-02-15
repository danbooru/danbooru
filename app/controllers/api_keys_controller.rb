class ApiKeysController < ApplicationController
  respond_to :html, :json, :xml

  def new
    @api_key = authorize ApiKey.new(user: CurrentUser.user, **permitted_attributes(ApiKey))
    respond_with(@api_key)
  end

  def create
    @api_key = authorize ApiKey.new(user: CurrentUser.user, **permitted_attributes(ApiKey))
    @api_key.save
    respond_with(@api_key, location: user_api_keys_path(CurrentUser.user.id))
  end

  def edit
    @api_key = authorize ApiKey.find(params[:id])
    respond_with(@api_key)
  end

  def update
    @api_key = authorize ApiKey.find(params[:id])
    @api_key.update(permitted_attributes(@api_key))
    respond_with(@api_key, location: user_api_keys_path(CurrentUser.user.id))
  end

  def index
    params[:search][:user_id] = params[:user_id] if params[:user_id].present?
    @api_keys = authorize ApiKey.visible(CurrentUser.user).paginated_search(params, count_pages: true)
    respond_with(@api_keys)
  end

  def destroy
    @api_key = authorize ApiKey.find(params[:id])
    @api_key.destroy
    respond_with(@api_key, location: user_api_keys_path(CurrentUser.user.id))
  end
end
