# frozen_string_literal: true

class MediaAssetsController < ApplicationController
  respond_to :html, :json, :xml, :js

  def index
    @media_assets = authorize MediaAsset.visible(CurrentUser.user).paginated_search(params, limit: per_page, max_limit: PostSets::Post::MAX_PER_PAGE, count_pages: false)
    @media_assets = @media_assets.includes(:post, :replaced_posts)
    @media_assets = @media_assets.includes(:media_metadata) if request.format.html?
    respond_with(@media_assets)
  end

  def show
    @media_asset = authorize MediaAsset.find(params[:id])

    if request.format.html?
      @post = Post.find_by_md5(@media_asset.md5)
      @visible_uma = @media_asset.upload_media_assets.visible(CurrentUser.user).select("*, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY id DESC) AS n")
      @visible_uma = UploadMediaAsset.from(@visible_uma).where("n < 6").select("*").order(id: :desc)
      @visible_uma = @visible_uma.includes(upload: :uploader)
    end

    respond_with(@media_asset)
  end

  def destroy
    @media_asset = authorize MediaAsset.find(params[:id])
    @media_asset.trash!(CurrentUser.user)

    respond_with(@media_asset, notice: "File deleted")
  end

  def image
    media_asset = authorize MediaAsset.find(params[:media_asset_id])
    variant = media_asset.variant(params[:variant])
    raise ActiveRecord::RecordNotFound if variant.nil?

    redirect_to variant.file_url, allow_other_host: true
  end
end
