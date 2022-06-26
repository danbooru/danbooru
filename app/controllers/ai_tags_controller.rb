# frozen_string_literal: true

class AITagsController < ApplicationController
  respond_to :js, :html, :json, :xml

  def index
    @ai_tags = authorize AITag.visible(CurrentUser.user).paginated_search(params, count_pages: false)
    @ai_tags = @ai_tags.includes(:media_asset, :tag, :post) if request.format.html?

    @mode = params.fetch(:mode, "gallery")
    @preview_size = params[:size].presence || cookies[:post_preview_size].presence || MediaAssetGalleryComponent::DEFAULT_SIZE

    respond_with(@ai_tags)
  end

  # Add the tag to the post, or remove the tag from the post.
  def tag
    @ai_tag = authorize AITag.find_by!(media_asset_id: params[:media_asset_id], tag_id: params[:tag_id])
    @post = @ai_tag.post

    if params[:mode] == "remove"
      @post.remove_tag(@ai_tag.tag.name)
      flash.now[:notice] = DText.format_text("Post ##{@post.id}: Removed [[#{@ai_tag.tag.pretty_name}]].", inline: true).html_safe
    else
      @post.add_tag(@ai_tag.tag.name)
      flash.now[:notice] = DText.format_text("Post ##{@post.id}: Added [[#{@ai_tag.tag.pretty_name}]].", inline: true).html_safe
    end

    @post.save
    if @post.invalid?
      flash.now[:notice] = DText.format_text("Couldn't update post ##{@post.id}: #{@post.errors.full_messages.join("; ")}", inline: true).html_safe
    end

    @preview_size = params[:size].presence || cookies[:post_preview_size].presence || PostGalleryComponent::DEFAULT_SIZE
    respond_with(@ai_tag)
  end
end
