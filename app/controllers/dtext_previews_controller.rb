class DtextPreviewsController < ApplicationController
  def create
    render :inline => "<%= format_text(params[:body], inline: params[:inline]) %>"
  end
end
