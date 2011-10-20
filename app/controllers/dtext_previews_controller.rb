class DtextPreviewsController < ApplicationController
  def create
    render :inline => "<%= format_text(params[:body]) %>"
  end
end
