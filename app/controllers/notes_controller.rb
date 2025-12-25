# frozen_string_literal: true

class NotesController < ApplicationController
  respond_to :html, :xml, :json, :js

  def index
    @notes = authorize Note.paginated_search(params)
    @notes = @notes.includes(:post) if request.format.html?

    respond_with(@notes)
  end

  def show
    @note = authorize Note.find(params[:id])
    respond_with(@note) do |format|
      format.html { redirect_to(post_path(@note.post, anchor: "note-#{@note.id}")) }
    end
  end

  def create
    @note = authorize Note.new(permitted_attributes(Note))
    @note.save

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
    @note.attributes = permitted_attributes(@note)
    authorize(@note).save

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
    @note = authorize Note.find(params[:id])
    @note.update(is_active: false)
    respond_with(@note)
  end

  def revert
    @note = authorize Note.find(params[:id])
    @version = @note.versions.find(params[:version_id])
    @note.revert_to!(@version)
    respond_with(@note)
  end

  def preview
    @note = authorize Note.new(body: params[:body])

    respond_with(@note, methods: [:sanitized_body])
  end
end
