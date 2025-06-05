# frozen_string_literal: true

class PostReplacementsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def new
    @post_replacement = authorize PostReplacement.new(post_id: params[:post_id], **permitted_attributes(PostReplacement))
    respond_with(@post_replacement)
  end

  def create
    @post_replacement = authorize PostReplacement.new(creator: CurrentUser.user, post_id: params[:post_id], **permitted_attributes(PostReplacement))
    @post_replacement.save

    respond_with(@post_replacement, notice: "Post replaced") do |format|
      format.html { redirect_to @post_replacement.post }
    end
  end

  def update
    @post_replacement = authorize PostReplacement.find(params[:id])
    @post_replacement.update(permitted_attributes(@post_replacement))

    respond_with(@post_replacement)
  end

  def index
    params[:search][:post_id] = params.delete(:post_id) if params.key?(:post_id)
    @post_replacements = authorize PostReplacement.paginated_search(params)
    @post_replacements = @post_replacements.includes(:creator, :old_media_asset, :media_asset, post: [:uploader, :media_asset]) if request.format.html?

    respond_with(@post_replacements)
  end

  def show
    @post_replacement = authorize PostReplacement.find(params[:id])

    respond_with(@post_replacement) do |format|
      format.html { redirect_to post_replacements_path(search: { id: @post_replacement.id }) }
    end
  end
end
