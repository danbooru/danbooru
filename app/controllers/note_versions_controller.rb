class NoteVersionsController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :member_only, :except => [:index, :show]
  
  def index
    @search = NoteVersion.search(params[:search])
    @note_versions = @search.paginate(:page => params[:page])
    respond_with(@note_versions)
  end
end
