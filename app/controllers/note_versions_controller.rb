class NoteVersionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @note_versions = NoteVersion.search(search_params).paginate(params[:page], :limit => params[:limit])
    @note_versions = @note_versions.includes(:updater) if request.format.html?
    respond_with(@note_versions)
  end
end
