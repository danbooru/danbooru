class MediaAsset < ApplicationRecord
  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :md5, :file_ext, :file_size, :image_width, :image_height)
    q = q.apply_default_order(params)
    q
  end
end
