class MediaAsset < ApplicationRecord
  has_one :media_metadata, dependent: :destroy

  def self.create_from_media_file!(media_file)
    create!(
      md5: media_file.md5,
      file_ext: media_file.file_ext,
      file_size: media_file.file_size,
      image_width: media_file.width,
      image_height: media_file.height,
      media_metadata: MediaMetadata.new(metadata: media_file.metadata),
    )
  end

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :md5, :file_ext, :file_size, :image_width, :image_height)
    q = q.apply_default_order(params)
    q
  end
end
