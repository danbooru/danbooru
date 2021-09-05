require "shellwords"

# A wrapper for the ffmpeg command.
class FFmpeg
  extend Memoist

  class Error < StandardError; end

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
    output = shell!("ffmpeg -i #{file.path.shellescape} -vf thumbnail=300 -frames:v 1 -y #{vp.path.shellescape}")
    Rails.logger.debug(output)

    MediaFile.open(vp)
  end

  # Get file metadata using ffprobe.
  # @see https://ffmpeg.org/ffprobe.html
  # @see https://gist.github.com/nrk/2286511
  # @return [Hash] a hash of the file's metadata
  def metadata
    output = shell!("ffprobe -v quiet -print_format json -show_format -show_streams #{file.path.shellescape}")
    json = JSON.parse(output)
    json.with_indifferent_access
  end

  def width
    video_channels.first[:width]
  end

  def height
    video_channels.first[:height]
  end

  def duration
    metadata.dig(:format, :duration).to_f
  end

  def video_channels
    metadata[:streams].select { |stream| stream[:codec_type] == "video" }
  end

  def audio_channels
    metadata[:streams].select { |stream| stream[:codec_type] == "audio" }
  end

  def has_audio?
    audio_channels.present?
  end

  def shell!(command)
    program = command.shellsplit.first
    output, status = Open3.capture2e(command)
    raise Error, "#{program} failed: #{output}" if !status.success?
    output
  end

  memoize :metadata
end
