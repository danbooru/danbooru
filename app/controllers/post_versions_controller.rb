# frozen_string_literal: true

class PostVersionsController < ApplicationController
  respond_to :html, :xml, :json
  respond_to :js, only: [:undo]

  def index
    set_version_comparison("current")
    @post_versions = authorize PostVersion.paginated_search(params)

    if request.format.html?
      @post_versions = @post_versions.includes(:updater, post: [:uploader, :media_asset, :versions])
    else
      @post_versions = @post_versions.includes(post: :versions)
    end

    respond_with(@post_versions)
  end

  def search
  end

  def undo
    @post_version = authorize PostVersion.find(params[:id])
    @post_version.undo!

    respond_with(@post_version, location: post_versions_path(search: { post_id: @post_version.post_id }))
  end
end
