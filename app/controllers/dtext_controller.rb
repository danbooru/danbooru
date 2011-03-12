class DtextController < ApplicationController
  def preview
    render :inline => "<h1 class=\"preview-header\">Preview</h1><%= format_text(params[:body]) %>"
  end
end
