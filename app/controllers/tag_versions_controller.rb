# frozen_string_literal: true

class TagVersionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    tag_id = params[:tag_id] || params[:search][:tag_id]
    tag_name = params[:search][:name_matches]
    updater_id = params[:updater_id] || params[:search][:updater_id]
    updater_name = params[:search][:updater_name]

    @tag = Tag.find(tag_id) if tag_id
    @tag = Tag.find_by_name(tag_name) if tag_name
    @updater = User.find(updater_id) if updater_id
    @updater = User.find_by_name(updater_name) if updater_name

    if request.format.html?
      @tag_versions = authorize TagVersion.visible(CurrentUser.user).paginated_search(params, defaults: { tag_id: @tag&.id, updater_id: @updater&.id, order: "updated_at" }, count_pages: true)
      @tag_versions = @tag_versions.includes(:tag, :updater, :previous_version)
    else
      @tag_versions = authorize TagVersion.visible(CurrentUser.user).paginated_search(params, defaults: { tag_id: @tag&.id, updater_id: @updater&.id })
    end

    respond_with(@tag_versions)
  end

  def show
    @tag_version = authorize TagVersion.find(params[:id])

    respond_with(@tag_version) do |format|
      format.html { redirect_to tag_versions_path(search: { id: @tag_version.id }) }
    end
  end
end
