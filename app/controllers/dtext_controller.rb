class DtextController < ApplicationController
  def preview
    render :inline => "<h3 class=\"preview-header\">Preview</h3><%= format_text(params[:body]) %>"
  end
end
