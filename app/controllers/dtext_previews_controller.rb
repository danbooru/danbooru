class DtextPreviewsController < ApplicationController
  def create
    @inline = params[:inline].to_s.truthy?
    @disable_mentions = params[:disable_mentions].to_s.truthy?
    @expanded_quote = params[:expanded_quote].to_s.truthy?

    render inline: "<%= format_text(params[:body], inline: @inline, disable_mentions: @disable_mentions, expanded_quote: @expanded_quote) %>"
  end
end
