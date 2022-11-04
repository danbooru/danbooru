# frozen_string_literal: true

require "shellwords"

# A wrapper for the ffmpeg command.
class FFmpeg
  extend Memoist

  class Error < StandardError; end

  attr_reader :file

  # Operate on a file with FFmpeg.
  #
  # @param file [MediaFile, String] A webm, mp4, gif, or apng file.
  def initialize(file)
    @file = file.is_a?(String) ? MediaFile.open(file) : file
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
  #
  # @see https://ffmpeg.org/ffprobe.html
  # @see https://gist.github.com/nrk/2286511
  #
  # @return [Hash] A hash of the file's metadata. Will be empty if reading the file failed for any reason.
  def metadata
    output = shell!("ffprobe -v quiet -print_format json -show_format -show_streams -show_packets #{file.path.shellescape}")
    json = JSON.parse(output)
    json.with_indifferent_access
  rescue Error => e
    { error: e.message.strip }.with_indifferent_access
  end

  def width
    video_stream[:width]
  end

  def height
    video_stream[:height]
  end

  # @see https://trac.ffmpeg.org/wiki/FFprobeTips#Duration
  # @return [Float, nil] The duration of the video or animation in seconds, or nil if unknown.
  def duration
    if metadata.dig(:format, :duration).present?
      metadata.dig(:format, :duration).to_f
    elsif playback_info.has_key?(:time)
      hours, minutes, seconds = playback_info[:time].split(/:/)
      hours.to_f*60*60 + minutes.to_f*60 + seconds.to_f
    else
      nil
    end
  end

  # @return [Integer, nil] The number of frames in the video or animation, or nil if unknown.
  def frame_count
    if video_stream.has_key?(:nb_frames)
      video_stream[:nb_frames].to_i
    elsif playback_info.has_key?(:frame)
      playback_info[:frame].to_i
    else
      nil
    end
  end

  # @return [Float, nil] The average frame rate of the video or animation, or nil if unknown.
  def frame_rate
    return nil if frame_count.nil? || duration.nil? || duration == 0
    frame_count / duration
  end

  def major_brand
    metadata.dig(:format, :tags, :major_brand)
  end

  def pix_fmt
    video_stream[:pix_fmt]
  end

  def video_codec
    video_stream[:codec_name]
  end

  # @return [Integer, nil] The bit rate of the video stream, in bits per second, or nil if it can't be calculated.
  def video_bit_rate
    if video_stream.has_key?(:bit_rate)
      video_stream[:bit_rate].to_i
    # .webm doesn't have the bit rate in the metadata, so we have to calculate it from the video stream size and duration.
    elsif video_size > 0 && duration > 0
      ((8.0 * video_size) / duration).to_i
    else
      nil
    end
  end

  def video_stream
    video_streams.first || {}
  end

  def video_streams
    metadata[:streams].to_a.select { |stream| stream[:codec_type] == "video" }
  end

  def audio_codec
    audio_stream[:codec_name]
  end

  # @return [Integer, nil] The bit rate of the audio stream, in bits per second, or nil if it can't be calculated.
  def audio_bit_rate
    if audio_stream.has_key?(:bit_rate)
      audio_stream[:bit_rate].to_i
    # .webm doesn't have the bit rate in the metadata, so we have to calculate it from the audio stream size and duration.
    elsif audio_size > 0 && duration > 0
      ((8.0 * audio_size) / duration).to_i
    else
      nil
    end
  end

  def audio_stream
    audio_streams.first || {}
  end

  def audio_streams
    metadata[:streams].to_a.select { |stream| stream[:codec_type] == "audio" }
  end

  def has_audio?
    audio_streams.present?
  end

  def packets
    metadata[:packets].to_a
  end

  def video_packets
    packets.select { |stream| stream[:codec_type] == "video" }
  end

  def audio_packets
    packets.select { |stream| stream[:codec_type] == "audio" }
  end

  # @return [Integer] The size of the compressed video stream in bytes.
  def video_size
    video_packets.pluck("size").map(&:to_i).sum
  end

  # @return [Integer] The size of the compressed audio stream in bytes.
  def audio_size
    audio_packets.pluck("size").map(&:to_i).sum
  end

  # @return [Boolean] True if the video is unplayable.
  def is_corrupt?
    error.present?
  end

  # @return [String, nil] The error message if the video is unplayable, or nil if no error.
  def error
    metadata[:error] || playback_info[:error]
  end

  # Decode the full video and return a hash containing the frame count, fps, runtime, and the sizes of the decompressed video and audio streams.
  def playback_info
    # XXX `-c copy` is faster, but it doesn't decompress the stream so it can't detect corrupt videos.
    output = shell!("ffmpeg -hide_banner -i #{file.path.shellescape} -f null /dev/null")

    # time_line = "frame=   10 fps=0.0 q=-0.0 Lsize=N/A time=00:00:00.48 bitrate=N/A speed= 179x"
    # time_info = { "frame"=>"10", "fps"=>"0.0", "q"=>"-0.0", "Lsize"=>"N/A", "time"=>"00:00:00.48", "bitrate"=>"N/A", "speed"=>"188x" }
    time_line = output.lines.grep(/\Aframe=/).first.chomp
    time_info = time_line.scan(/\S+=\s*\S+/).map { |pair| pair.split(/=\s*/) }.to_h

    # size_line = "video:36kBkB audio:16kB subtitle:0kB other streams:0kB global headers:0kB muxing overhead: unknown"
    # size_info = { "video" => 36000, "audio" => 16000, "subtitle" => 0, "other streams" => 0, "global headers" => 0, "muxing overhead" => 0 }
    size_line = output.lines.grep(/\Avideo:/).first.chomp
    size_info = size_line.scan(/[a-z ]+: *[a-z0-9]+/i).map do |pair|
      key, value = pair.split(/: */)
      [key.strip, value.to_i * 1000] # [" audio", "16kB"] => ["audio", 16000]
    end.to_h

    { **time_info, **size_info }.with_indifferent_access
  rescue Error => e
    { error: e.message.strip }.with_indifferent_access
  end

  def shell!(command)
    program = command.shellsplit.first
    output, status = Open3.capture2e(command)
    raise Error, "#{program} failed: #{output}" if !status.success?
    output
  end

  memoize :metadata, :playback_info, :frame_count, :duration, :error, :video_size, :audio_size
end
