# frozen_string_literal: true

class ApiKeysController < ApplicationController
  before_action :requires_reauthentication
  respond_to :html, :json, :xml

  def index
    params[:search][:user_id] = params[:user_id] if params[:user_id].present?
    @api_keys = authorize ApiKey.visible(CurrentUser.user).paginated_search(params, count_pages: true)
    respond_with(@api_keys)
  end

  def new
    @api_key = authorize ApiKey.new(user: CurrentUser.user, **permitted_attributes(ApiKey))
    respond_with(@api_key)
  end

  def edit
    @api_key = authorize ApiKey.find(params[:id])
    respond_with(@api_key)
  end

  def create
    @api_key = authorize ApiKey.new(user: CurrentUser.user, request: request, **permitted_attributes(ApiKey))

    if @api_key.save
      respond_to do |format|
        format.html { render :create }
        format.json { render json: @api_key.serializable_hash.merge("key" => @api_key.key) }
        format.xml { render xml: @api_key.serializable_hash.merge("key" => @api_key.key).to_xml }
      end
    else
      respond_with(@api_key, location: user_api_keys_path(CurrentUser.user.id))
    end
  end

  def update
    @api_key = authorize ApiKey.find(params[:id])
    @api_key.update(request: request, **permitted_attributes(@api_key))

    respond_with(@api_key, location: user_api_keys_path(CurrentUser.user.id))
  end

  def destroy
    @api_key = authorize ApiKey.find(params[:id])
    @api_key.request = request
    @api_key.destroy

    respond_with(@api_key, location: user_api_keys_path(CurrentUser.user.id))
  end
end
