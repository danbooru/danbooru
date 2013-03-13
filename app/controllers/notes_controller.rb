class NotesController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_filter :member_only, :except => [:index, :show]
  before_filter :pass_html_id, :only => [:create]
  
  def search
  end
  
  def index
    if params[:group_by] == "note"
      index_by_note
    else
      index_by_post
    end
  end
  
  def show
    @note = Note.find(params[:id])
    respond_with(@note)
  end
  
  def create
    @note = Note.create(params[:note])
    respond_with(@note) do |fmt|
      fmt.json do
        render :json => @note.to_json(:methods => [:html_id])
      end
    end
  end
  
  def update
    @note = Note.find(params[:id])
    @note.update_attributes(params[:note])
    respond_with(@note)
  end
  
  def destroy
    @note = Note.find(params[:id])
    @note.update_attribute(:is_active, false)
    respond_with(@note)
  end
  
  def revert
    @note = Note.find(params[:id])
    @version = NoteVersion.find(params[:version_id])
    @note.revert_to!(@version)
    respond_with(@note)
  end

private
  def pass_html_id
    if params[:note] && params[:note][:html_id]
      response.headers["X-Html-Id"] = params[:note][:html_id]
    end
  end

  def index_by_post
    @post_set = PostSets::Note.new(params)
    @posts = @post_set.posts
    respond_with(@posts) do |format|
      format.html {render :action => "index_by_post"}
    end
  end

  def index_by_note
    @notes = Note.search(params[:search]).order("id desc").paginate(params[:page], :search_count => params[:search])
    respond_with(@notes) do |format|
      format.html {render :action => "index_by_note"}
    end
  end
end
