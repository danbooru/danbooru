# frozen_string_literal: true

class DtextPreviewsController < ApplicationController
  def create
    @inline = params[:inline].to_s.truthy?
    @disable_mentions = params[:disable_mentions].to_s.truthy?
    @media_embeds = params[:media_embeds].to_s.truthy?
    @dtext = authorize DText.new(params[:body], inline: @inline, disable_mentions: @disable_mentions, media_embeds: @media_embeds), policy_class: DtextPolicy
    @html = @dtext.format_text

    render html: @html
  end
end
