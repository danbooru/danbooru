class MediaAsset < ApplicationRecord
  has_one :media_metadata, dependent: :destroy
  delegate :metadata, to: :media_metadata

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :md5, :file_ext, :file_size, :image_width, :image_height)
    q = q.apply_default_order(params)
    q
  end

  def file=(file_or_path)
    media_file = file_or_path.is_a?(MediaFile) ? file_or_path : MediaFile.open(file_or_path)

    self.md5 = media_file.md5
    self.file_ext = media_file.file_ext
    self.file_size = media_file.file_size
    self.image_width = media_file.width
    self.image_height = media_file.height
    self.media_metadata = MediaMetadata.new(file: media_file)
  end

  def is_animated?
    is_animated_gif? || is_animated_png?
  end

  def is_animated_gif?
    file_ext == "gif" && metadata.fetch("GIF:FrameCount", 1) > 1
  end

  def is_animated_png?
    file_ext == "png" && metadata.fetch("PNG:AnimationFrames", 1) > 1
  end
end