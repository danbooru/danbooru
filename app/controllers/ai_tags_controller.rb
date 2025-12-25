# frozen_string_literal: true

class AITagsController < ApplicationController
  respond_to :js, :html, :json, :xml

  def index
    limit = params[:limit].presence || CurrentUser.user.per_page
    @mode = params.fetch(:mode, "gallery")
    @preview_size = params[:size].presence || cookies[:post_preview_size].presence || MediaAssetGalleryComponent::DEFAULT_SIZE
    params[:search][:is_posted] ||= "true" if request.format.html?

    @ai_tags = authorize AITag.visible(CurrentUser.user).paginated_search(params, limit: limit, count_pages: false)
    @ai_tags = @ai_tags.includes(:tag, media_asset: :post) if request.format.html?

    respond_with(@ai_tags)
  end

  # Add the tag to the post, or remove the tag from the post.
  def tag
    @ai_tag = authorize AITag.find_by!(media_asset_id: params[:media_asset_id], tag_id: params[:tag_id])
    @post = @ai_tag.post

    if params[:tag].present?
      @post.add_tag(params[:tag])
      notice = "Post ##{@post.id}: Reverted to [[#{params[:tag]}]]."
    elsif params[:mode] == "remove"
      @post.remove_tag(@ai_tag.tag.name)
      notice = "Post ##{@post.id}: Removed [[#{@ai_tag.tag.pretty_name}]]."
    else
      @post.add_tag(@ai_tag.tag.name)
      notice = "Post ##{@post.id}: Added [[#{@ai_tag.tag.pretty_name}]]."
    end

    @post.save
    @ai_tag.errors.add(:base, "Couldn't update post ##{@post.id}: #{@post.errors.full_messages.join("; ")}") if @post.invalid?

    @preview_size = params[:size].presence || cookies[:post_preview_size].presence || PostGalleryComponent::DEFAULT_SIZE
    respond_with(@ai_tag, notice: notice)
  end
end
