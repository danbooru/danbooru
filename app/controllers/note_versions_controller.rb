class NoteVersionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @note_versions = NoteVersion.search(search_params).paginate(params[:page], :limit => params[:limit])
    respond_with(@note_versions) do |format|
      format.html { @note_versions = @note_versions.includes(:updater) }
      format.xml do
        render :xml => @note_versions.to_xml(:root => "note-versions")
      end
    end
  end
end
