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

  # Generate a .png preview image for a video or animation. Generates
  # thumbnails intelligently by avoiding blank frames.
  #
  # @return [MediaFile] the preview image
  def smart_video_preview
    vp = Tempfile.new(["video-preview", ".png"], binmode: true)

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
    video_streams.first[:width]
  end

  def height
    video_streams.first[:height]
  end

  def duration
    metadata.dig(:format, :duration).to_f
  end

  def frame_count
    if video_streams.first.has_key?(:nb_frames)
      video_streams.first[:nb_frames].to_i
    else
      (duration * frame_rate).to_i
    end
  end

  # @return [Float, nil] The frame rate of the video or animation, or nil if
  # unknown. The frame rate can be unknown for animated PNGs that have zero
  # delay between frames.
  def frame_rate
    rate = video_streams.first[:avg_frame_rate] # "100/57"
    numerator, denominator = rate.split("/")

    if numerator.to_f == 0 || denominator.to_f == 0
      nil
    else
      (numerator.to_f / denominator.to_f)
    end
  end

  def video_streams
    metadata[:streams].select { |stream| stream[:codec_type] == "video" }
  end

  def audio_streams
    metadata[:streams].select { |stream| stream[:codec_type] == "audio" }
  end

  def has_audio?
    audio_streams.present?
  end

  def shell!(command)
    program = command.shellsplit.first
    output, status = Open3.capture2e(command)
    raise Error, "#{program} failed: #{output}" if !status.success?
    output
  end

  memoize :metadata
end
