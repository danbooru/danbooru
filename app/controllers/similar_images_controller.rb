class SimilarImagesController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @image_hashes = ImageHash.includes(:post).paginated_search(params)
    respond_with(@image_hashes)
  end

  def search
    @image_hash = ImageHash.new_from_source(search_params)
    @image_hashes = ImageHash.search(search_params.merge(image_hash: @image_hash)).paginate(params[:page], limit: params[:limit]).includes(post: [:uploader])
    @image_hashes.each { |h| h.comparison_hash = @image_hash }

    respond_with(image_hash: @image_hash, similar_image_hashes: @image_hashes)
  end
end
