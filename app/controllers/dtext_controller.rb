class DtextController < ApplicationController
  def preview
    render :inline => "<h1>Preview</h1><%= format_text(params[:body]) %>"
  end
end
