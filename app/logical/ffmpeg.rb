# frozen_string_literal: true

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
  #
  # @see https://ffmpeg.org/ffprobe.html
  # @see https://gist.github.com/nrk/2286511
  #
  # @return [Hash] A hash of the file's metadata. Will be empty if reading the file failed for any reason.
  def metadata
    output = shell!("ffprobe -v quiet -print_format json -show_format -show_streams #{file.path.shellescape}")
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

  def pix_fmt
    video_stream[:pix_fmt]
  end

  def video_codec
    video_stream[:codec_name]
  end

  def video_stream
    video_streams.first || {}
  end

  def video_streams
    metadata[:streams].to_a.select { |stream| stream[:codec_type] == "video" }
  end

  def audio_streams
    metadata[:streams].to_a.select { |stream| stream[:codec_type] == "audio" }
  end

  def has_audio?
    audio_streams.present?
  end

  # @return [Boolean] True if the video is unplayable.
  def is_corrupt?
    error.present?
  end

  # @return [String, nil] The error message if the video is unplayable, or nil if no error.
  def error
    metadata[:error] || playback_info[:error]
  end

  # Decode the full video and return a hash containing the frame count, fps, and runtime.
  def playback_info
    output = shell!("ffmpeg -i #{file.path.shellescape} -f null /dev/null")
    status_line = output.lines.grep(/\Aframe=/).first.chomp

    # status_line = "frame=   10 fps=0.0 q=-0.0 Lsize=N/A time=00:00:00.48 bitrate=N/A speed= 179x"
    # info = {"frame"=>"10", "fps"=>"0.0", "q"=>"-0.0", "Lsize"=>"N/A", "time"=>"00:00:00.48", "bitrate"=>"N/A", "speed"=>"188x"}
    info = status_line.scan(/\S+=\s*\S+/).map { |pair| pair.split(/=\s*/) }.to_h
    info.with_indifferent_access
  rescue Error => e
    { error: e.message.strip }.with_indifferent_access
  end

  def shell!(command)
    program = command.shellsplit.first
    output, status = Open3.capture2e(command)
    raise Error, "#{program} failed: #{output}" if !status.success?
    output
  end

  memoize :metadata, :playback_info, :frame_count, :duration, :error
end
