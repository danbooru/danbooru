class NotesController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_action :member_only, :except => [:index, :show, :search]

  def search
  end

  def index
    @notes = Note.paginated_search(params).includes(model_includes(params))
    respond_with(@notes)
  end

  def show
    @note = Note.find(params[:id])
    respond_with(@note) do |format|
      format.html { redirect_to(post_path(@note.post, anchor: "note-#{@note.id}")) }
    end
  end

  def create
    @note = Note.create(note_params(:create).merge(creator: CurrentUser.user))
    respond_with(@note) do |fmt|
      fmt.json do
        if @note.errors.any?
          render :json => {:success => false, :reasons => @note.errors.full_messages}.to_json, :status => 422
        else
          render :json => @note.to_json(:methods => [:html_id])
        end
      end
    end
  end

  def update
    @note = Note.find(params[:id])
    @note.update(note_params(:update))
    respond_with(@note) do |format|
      format.json do
        if @note.errors.any?
          render :json => {:success => false, :reasons => @note.errors.full_messages}.to_json, :status => 422
        else
          render :json => @note.to_json
        end
      end
    end
  end

  def destroy
    @note = Note.find(params[:id])
    @note.update(is_active: false)
    respond_with(@note)
  end

  def revert
    @note = Note.find(params[:id])
    @version = @note.versions.find(params[:version_id])
    @note.revert_to!(@version)
    respond_with(@note)
  end

  private

  def default_includes(params)
    if ["json", "xml"].include?(params[:format])
      [:creator]
    else
      [:creator, :post]
    end
  end

  def note_params(context)
    permitted_params = %i[x y width height body]
    permitted_params += %i[post_id html_id] if context == :create

    params.require(:note).permit(permitted_params)
  end
end
