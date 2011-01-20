class NotesController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :member_only, :except => [:index, :show]
  
  def index
    @search = Note.search(params[:search])
    @notes = @search.paginate(:page => params[:page])
    respond_with(@notes)
  end
  
  def show
    @note = Note.find(params[:id])
    respond_with(@note)
  end
  
  def create
    @note = Note.create(params[:note])
    respond_with(@note)
  end
  
  def update
    @note = Note.find(params[:id])
    @note.update_attributes(params[:note])
    respond_with(@note)
  end
  
  def destroy
    @note = Note.find(params[:id])
    @note.destroy
    respond_with(@note)
  end
  
  def revert
    @note = Note.find(params[:id])
    @version = NoteVersion.find(params[:version_id])
    @note.revert_to!(@version)
    respond_with(@note)
  end
end
