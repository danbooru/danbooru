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
  # @raise [Error] The error if generating the preview image fails (probably because FFmpeg couldn't decode the GIF or video)
  def smart_video_preview!
    vp = Danbooru::Tempfile.new(["danbooru-video-preview-#{file.md5}-", ".png"], binmode: true)

    # https://ffmpeg.org/ffmpeg.html#Main-options
    # https://ffmpeg.org/ffmpeg-filters.html#thumbnail
    output = shell!("ffmpeg -i #{file.path.shellescape} -vf thumbnail=300 -frames:v 1 -y #{vp.path.shellescape}")

    MediaFile.open(vp)
  end

  # @return [MediaFile, nil] The preview image, or nil on error.
  def smart_video_preview
    smart_video_preview!
  rescue Error
    nil
  end

  # Get file metadata using ffprobe.
  #
  # @see https://ffmpeg.org/ffprobe.html
  # @see https://gist.github.com/nrk/2286511
  #
  # @return [Hash] A hash of the file's metadata. Will be empty if reading the file failed for any reason.
  def metadata
    output = shell!("ffprobe -v quiet -print_format json -show_format -show_streams -show_packets #{file.path.shellescape}")
    output.parse_json || {}
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

  # @return [Integer, nil] The number of frames in the video or animation, or nil if unknown. If the video has multiple
  #   streams, this will be the frame count of the longest stream. Note that a static AVIF image can contain up to four
  #   streams: one for the static image, one for an auxiliary video, and an optional alpha channel stream for each.
  def frame_count
    if video_streams.pluck(:nb_frames).compact.present?
      video_streams.pluck(:nb_frames).map(&:to_i).max
    elsif playback_info.key?(:frame)
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

  # @return [String, nil] The pixel format of the video stream, or nil if unknown. Common values include yuv420p,
  #   yuv422p, yuv444p, rgb24, bgr24, gray, etc.
  # @see https://github.com/FFmpeg/FFmpeg/blob/master/libavutil/pixfmt.h
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

  # @return [Boolean] True if the file has an audio track. The audio track may be silent.
  def has_audio?
    audio_streams.present?
  end

  # @return [Float, nil] The total duration in seconds of all silent sections of the audio track.
  #   Nil if the file doesn't have an audio track.
  def silence_duration
    playback_info[:silence].pluck("silence_duration").sum if has_audio?
  end

  # @return [Float, nil] The percentage of the video that is silent, from 0% to 100%, or nil if the file doesn't
  #   have an audio track. If the silence percentage is 100%, then the audio track is totally silent.
  def silence_percentage
    return nil if !has_audio? || duration.to_f == 0.0
    (silence_duration.to_f / duration).clamp(0.0, 1.0)
  end

  # The average loudness of the audio track, as a percentage of max volume. 0% is silent and 100% is max volume.
  #
  # The average loudness value ignores silent or quiet sections of the audio. 7% is the standard
  # average loudness for TV programs. 15% to 30% is typical for music streaming services.
  #
  # @return [Float, nil] The average loudness as a percent, or nil if the file doesn't have an audio track.
  # @see https://en.wikipedia.org/wiki/EBU_R_128
  def average_loudness
    10.pow(average_loudness_lufs / 20.0) if average_loudness_lufs.present?
  end

  # The average loudness of the audio track, in LUFS units. -70.0 is silent and 0.0 is max volume.
  #
  # The average loudness value ignores silent or quiet sections of the audio. -23.0 LUFS is the
  # standard average loudness for TV programs. -10.0 to -16.0 is typical for music streaming services.
  #
  # @return [Float, nil] The average loudness in LUFS, or nil if the file doesn't have an audio track.
  # @see https://en.wikipedia.org/wiki/EBU_R_128
  def average_loudness_lufs
    playback_info.dig(:ebur128, :I) if has_audio?
  end

  # The loudness range of the audio track, in LU (loudness units, where 1 LU = 1 dB). The loudness
  # range is roughly the difference between the quietest sound and the loudest sound (i.e., the
  # dynamic range). A typical loudness range for music is around 5 to 10 LU.
  #
  # This is based on measuring loudness in 3-second intervals, ignoring silence, so it's not very
  # meaningful for very short videos or videos that are mostly silent.
  #
  # @return [Float, nil] The loudness range in LU, or nil if the file doesn't have an audio track.
  # @see https://en.wikipedia.org/wiki/EBU_R_128
  # @see https://tech.ebu.ch/docs/tech/tech3342.pdf (EBU Tech 3343 - Loudness Range: A Measure to Supplement EBU R 128 Loudness Normalization)
  def loudness_range
    playback_info.dig(:ebur128, :LRA) if has_audio?
  end

  # The peak loudness of the audio track, as a percentage of max volume. 1.0 is 100% volume, 0.5 is
  # 50% volume, 0.0 is 0% volume, etc.
  #
  # This is the true peak loudness, which means it measures the true loudness even if the audio is clipped.
  # If the peak loudness if above 1.0, it means the audio is clipped.
  #
  # @return [Float, nil] The peak loudness in dBFS, or nil if the file doesn't have an audio track.
  # @see https://en.wikipedia.org/wiki/EBU_R_128
  def peak_loudness
    10.pow(peak_loudness_dbfs / 20.0) if peak_loudness_dbfs.present?
  end

  # The peak loudness of the audio track, in dBFS (decibels referenced to full scale). 0.0 is 100%
  # volume, -6.0 is 50% volume, -20.0 is 10% volume, -40.0 is 1% volume, etc.
  #
  # @return [Float, nil] The peak loudness in dBFS, or nil if the file doesn't have an audio track.
  # @see https://en.wikipedia.org/wiki/DBFS
  def peak_loudness_dbfs
    playback_info.dig(:ebur128, :Peak) if has_audio?
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
    # https://ffmpeg.org/ffmpeg-filters.html#silencedetect
    # https://ffmpeg.org/ffmpeg-filters.html#ebur128-1
    # XXX `-c copy` is faster, but it doesn't decompress the stream so it can't detect corrupt videos.
    output = shell!("ffmpeg -hide_banner -i #{file.path.shellescape} -af silencedetect=noise=0.0001:duration=0.25s,ebur128=metadata=1:dualmono=true:peak=true -f null /dev/null")
    lines = output.split(/\r\n|\r|\n/)

    # time_line = "frame=   10 fps=0.0 q=-0.0 Lsize=N/A time=00:00:00.48 bitrate=N/A speed= 179x"
    # time_info = { "frame"=>"10", "fps"=>"0.0", "q"=>"-0.0", "Lsize"=>"N/A", "time"=>"00:00:00.48", "bitrate"=>"N/A", "speed"=>"188x" }
    time_line = lines.grep(/\Aframe=/).last.strip
    time_info = time_line.scan(/\S+=\s*\S+/).map { |pair| pair.split(/=\s*/) }.to_h

    # size_line = "[out#0/null @ 0x7f0b1ba2f300] video:36kBkB audio:16kB subtitle:0kB other streams:0kB global headers:0kB muxing overhead: unknown"
    # size_info = { "video" => 36000, "audio" => 16000, "subtitle" => 0, "other streams" => 0, "global headers" => 0, "muxing overhead" => 0 }
    size_line = lines.grep(/\[.*\] video:/).last.to_s.gsub(/\A\[.*\]/, "").strip
    size_info = size_line.scan(/[a-z ]+: *[a-z0-9]+/i).map do |pair|
      key, value = pair.split(/: */)
      [key.strip, value.to_i * 1000] # [" audio", "16kB"] => ["audio", 16000]
    end.to_h

    # [silencedetect @ 0x561855af1040] silence_start: -0.00133333e=N/A speed=  25x
    # [silencedetect @ 0x561855af1040] silence_end: 12.052 | silence_duration: 12.0533
    silence_info = lines.grep(/silence_duration/).map do |line|
      line.scan(/[a-z_]+: *[0-9.]+/i).map do |pair|
        key, value = pair.split(/: */)
        [key, value.to_f]
      end.to_h
    end

    # [Parsed_ebur128_1 @ 0x5586b53889c0] Summary:
    #
    #   Integrated loudness:
    #     I:         -20.1 LUFS
    #     Threshold: -30.7 LUFS
    #
    #   Loudness range:
    #     LRA:         5.8 LU
    #     Threshold: -40.6 LUFS
    #     LRA low:   -24.0 LUFS
    #     LRA high:  -18.2 LUFS
    #
    #   True peak:
    #     Peak:       -2.2 dBFS
    ebur128_index = lines.rindex { |line| /Parsed_ebur128.*Summary:/ === line }

    if ebur128_index
      ebur128_lines = lines[ebur128_index..ebur128_index + 13].join("\n")
      ebur128_info = ebur128_lines.scan(/^ *[a-z ]+: *-?(?:inf|[0-9.]+) (?:LUFS|LU|dBFS)$/i).map do |pair|
        key, value = pair.split(/: */)
        value = -1000.0 if value == "-inf dBFS" # "Peak: -inf dBFS" for silent audio tracks.
        [key.strip.tr(" ", "_"), value.to_f] # ["LRA low", "-34.3 LUFS"] => ["lra_low", -34.3]
      end.to_h
    end

    { **time_info, **size_info, silence: silence_info, ebur128: ebur128_info.to_h }.with_indifferent_access
  rescue Error => e
    { error: e.message.strip }.with_indifferent_access
  end

  def shell!(command)
    program = command.shellsplit.first
    output, status = Open3.capture2e(command)
    raise Error, "#{program} failed: #{parse_errors(output)}" if !status.success?
    output.force_encoding("ASCII-8BIT")
  end

  def parse_errors(output)
    output.split(/\r?\n/).grep(/^(Error|\[\w+ @ 0x\h+\])/).uniq.join("\n")
  end

  memoize :metadata, :playback_info, :frame_count, :duration, :error, :video_size, :audio_size
end
