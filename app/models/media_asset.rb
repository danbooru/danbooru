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

  # @see https://exiftool.org/TagNames/JPEG.html
  # @see https://exiftool.org/TagNames/PNG.html
  # @see https://danbooru.donmai.us/posts?tags=exif:File:ColorComponents=1
  # @see https://danbooru.donmai.us/posts?tags=exif:PNG:ColorType=Grayscale
  def is_greyscale?
    metadata["File:ColorComponents"] == 1 ||
    metadata["PNG:ColorType"] == "Grayscale" ||
    metadata["PNG:ColorType"] == "Grayscale with Alpha"

    # Not always accurate:
    # metadata["ICC-header:ColorSpaceData"] == "GRAY" ||
    # metadata["XMP-photoshop:ColorMode"] == "Grayscale" ||
    # metadata["XMP-photoshop:ICCProfileName"] == "EPSON Gray - Gamma 2.2" ||
    # metadata["XMP-photoshop:ICCProfileName"] == "Gray Gamma 2.2"
  end

  # https://exiftool.org/TagNames/EXIF.html
  def is_rotated?
    metadata["IFD0:Orientation"].in?(["Rotate 90 CW", "Rotate 270 CW", "Rotate 180"])
  end

  # Some animations technically have a finite loop count, but loop for hundreds
  # or thousands of times. Only count animations with a low loop count as non-repeating.
  def is_non_repeating_animation?
    loop_count.in?(0..10)
  end

  # @see https://exiftool.org/TagNames/GIF.html
  # @see https://exiftool.org/TagNames/PNG.html
  # @see https://danbooru.donmai.us/posts?tags=-exif:GIF:AnimationIterations=Infinite+animated_gif
  # @see https://danbooru.donmai.us/posts?tags=-exif:PNG:AnimationPlays=inf+animated_png
  def loop_count
    return Float::INFINITY if metadata["GIF:AnimationIterations"] == "Infinite"
    return Float::INFINITY if metadata["PNG:AnimationPlays"] == "inf"
    return metadata["GIF:AnimationIterations"] if metadata["GIF:AnimationIterations"].present?
    return metadata["PNG:AnimationPlays"] if metadata["PNG:AnimationPlays"].present?

    # If the AnimationIterations tag isn't present, then it's counted as a loop count of 0.
    return 0 if is_animated_gif? && metadata["GIF:AnimationIterations"].nil?

    nil
  end
end
