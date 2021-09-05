class FFmpeg
  attr_reader :file

  # Operate on a file with FFmpeg.
  # @param file [File, String] a webm, mp4, gif, or apng file
  def initialize(file)
    @file = file.is_a?(String) ? File.open(file) : file
  end

  # Generate a .jpg preview image for a video or animation. Generates
  # thumbnails intelligently by avoiding blank frames.
  #
  # @return [MediaFile] the preview image
  def smart_video_preview
    vp = Tempfile.new(["video-preview", ".jpg"], binmode: true)

    # https://ffmpeg.org/ffmpeg.html#Main-options
    # https://ffmpeg.org/ffmpeg-filters.html#thumbnail
    ffmpeg_out, status = Open3.capture2e("ffmpeg -i #{file.path} -vf thumbnail=300 -frames:v 1 -y #{vp.path}")
    raise "ffmpeg failed: #{ffmpeg_out}" if !status.success?
    Rails.logger.debug(ffmpeg_out)

    MediaFile.open(vp)
  end
end
