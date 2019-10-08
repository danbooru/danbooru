class NoteVersionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @note_versions = NoteVersion.paginated_search(params)
    @note_versions = @note_versions.includes(:updater) if request.format.html?
    respond_with(@note_versions)
  end
end
