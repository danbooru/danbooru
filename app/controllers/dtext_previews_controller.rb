class DtextPreviewsController < ApplicationController
  def create
    @inline = params[:inline].to_s.truthy?
    @disable_mentions = params[:disable_mentions].to_s.truthy?

    render inline: "<%= format_text(params[:body], inline: @inline, disable_mentions: @disable_mentions) %>"
  end
end
