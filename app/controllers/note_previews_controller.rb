class NotePreviewsController < ApplicationController
  respond_to :json

  def show
    @body = NoteSanitizer.sanitize(params[:body].to_s)
    respond_with(@body) do |format|
      format.json do
        render :json => {:body => @body}.to_json
      end
    end
  end
end
