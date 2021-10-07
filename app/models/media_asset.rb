class MediaAsset < ApplicationRecord
  has_one :media_metadata, dependent: :destroy
  delegate :metadata, to: :media_metadata
  delegate :is_animated?, :is_animated_gif?, :is_animated_png?, :is_non_repeating_animation?, :is_greyscale?, :is_rotated?, to: :metadata

  enum status: {
    processing: 100,
    active: 200,
    deleted: 300,
    expunged: 400,
  }

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :md5, :file_ext, :file_size, :image_width, :image_height, :media_metadata)

    if params[:metadata].present?
      q = q.joins(:media_metadata).merge(MediaMetadata.search(metadata: params[:metadata]))
    end

    q.apply_default_order(params)
  end

  def file=(file_or_path)
    media_file = file_or_path.is_a?(MediaFile) ? file_or_path : MediaFile.open(file_or_path)

    self.md5 = media_file.md5
    self.file_ext = media_file.file_ext
    self.file_size = media_file.file_size
    self.image_width = media_file.width
    self.image_height = media_file.height
    self.duration = media_file.duration
    self.media_metadata = MediaMetadata.new(file: media_file)
  end
end
