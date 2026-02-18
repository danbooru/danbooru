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
    # "-vf 'select=eq(n\\,0)+eq(key\\,1)+gt(scene\\,0.015),loop=loop=-1:size=2,trim=start_frame=1' -frames:v 1 -f image2"
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
  memoize def metadata
    output = shell!("ffprobe -v quiet -print_format json -show_format -show_streams -show_packets -show_frames #{file.path.shellescape}")
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
    container_duration || playback_duration
  end

  # @return [Float, nil] The duration of the video in seconds, according to the container metadata. May not match the
  #   true duration of the video in case the container metadata is wrong or the video is truncated.
  memoize def container_duration
    metadata.dig(:format, :duration).to_f if metadata.dig(:format, :duration).present?
  end

  # @return [Float, nil] The true duration of the video in seconds, as determined by actually playing it.
  memoize def playback_duration
    playback_info[:out_time_us].to_f / 1_000_000.0 if playback_info[:out_time_us].present?
  end

  # @return [Integer, nil] The number of frames in the video or animation, or nil if unknown. If the video has multiple
  #   streams, this will be the frame count of the longest stream. Note that a static AVIF image can contain up to four
  #   streams: one for the static image, one for an auxiliary video, and an optional alpha channel stream for each.
  memoize def frame_count
    if video_streams.pluck(:nb_frames).compact.present?
      video_streams.pluck(:nb_frames).map(&:to_i).max
    elsif playback_info.key?(:frame)
      playback_info[:frame].to_i
    else
      nil
    end
  end

  # @return [Array<Integer>] The duration of each video frame in milliseconds. The durations may be different if the
  #   video has a variable frame rate. If there are multiple video streams, this will be the first stream, and if there
  #   are no video streams, this will be an empty array.
  memoize def frame_durations
    # video_stream[:frames].pluck(:duration) # XXX Duration is only available for .webm files, not .mp4
    video_stream[:frames].pluck(:best_effort_timestamp_time).push(playback_duration).each_cons(2).map do |before, after|
      ((after.to_f - before.to_f) * 1000).round
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

  # @return [String, nil] The video codec of the first video stream, or nil if there is no video.
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

  # @return [Hash] A hash containing information about the first video stream in the file (if there are
  #   multiple), or an empty hash if there are no video streams.
  def video_stream
    video_streams.first || {}
  end

  # @return [Array<Hash>] An array of hashes for each video stream in the file.
  def video_streams
    metadata[:streams].to_a.select { |stream| stream[:codec_type] == "video" }.each do |stream|
      stream[:packets] = packets.select { |frame| frame[:codec_type] == "video" && frame[:stream_index] == stream[:index] }
      stream[:frames] = frames.select { |frame| frame[:media_type] == "video" && frame[:stream_index] == stream[:index] }
    end
  end

  # @return [String, nil] The audio codec of the audio stream, or nil if there is no audio.
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

  # @return [Hash] A hash containing information about the first audio stream in the file (if there are
  #   multiple), or an empty hash if there are no audio streams.
  def audio_stream
    audio_streams.first || {}
  end

  # @return [Array<Hash>] An array of hashes for each audio stream in the file.
  def audio_streams
    metadata[:streams].to_a.select { |stream| stream[:codec_type] == "audio" }.each do |stream|
      stream[:packets] = packets.select { |frame| frame[:codec_type] == "audio" && frame[:stream_index] == stream[:index] }
      stream[:frames] = frames.select { |frame| frame[:media_type] == "audio" && frame[:stream_index] == stream[:index] }
    end
  end

  # @return [Boolean] True if the file has an audio track. The audio track may be silent.
  def has_audio?
    audio_streams.present?
  end

  # @return [Float, nil] The total duration in seconds of all silent sections of the audio track.
  #   Nil if the file doesn't have an audio track.
  def silence_duration
    playback_info[:silence].to_a.pluck("silence_duration").sum if has_audio?
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

  # @return [Array<Hash>] An array of hashes for each video or audio frame in the file. Note that videos can have
  #   multiple video or audio streams, so each frame has a stream index to distinguish each stream.
  def frames
    metadata[:packets_and_frames].to_a.select { |data| data[:type] == "frame" }
  end

  # @return [Array<Hash>] An array of hashes for each video or audio packet in the file. A packet is a compressed chunk
  #   of data which may contain multiple frames. Note that videos can have multiple video or audio streams, so each
  #   packet has a stream index to distinguish each stream.
  def packets
    metadata[:packets_and_frames].to_a.select { |data| data[:type] == "packet" }
  end

  # @return [Array<Hash>] An array of hashes for each video packet in the file.
  def video_packets
    packets.select { |stream| stream[:codec_type] == "video" }
  end

  # @return [Array<Hash>] An array of hashes for each audio packet in the file.
  def audio_packets
    packets.select { |stream| stream[:codec_type] == "audio" }
  end

  # @return [Integer] The total compressed size of all video streams in bytes, or 0 if there are no video streams.
  memoize def video_size
    video_packets.pluck("size").map(&:to_i).sum
  end

  # @return [Integer] The total compressed size of all audio streams in bytes, or 0 if there are no audio streams.
  memoize def audio_size
    audio_packets.pluck("size").map(&:to_i).sum
  end

  # @return [Boolean] True if the video is unplayable.
  def is_corrupt?
    error.present?
  end

  # @return [String, nil] The error message if the video is unplayable, or nil if no error.
  memoize def error
    metadata[:error] || playback_info[:error]
  end

  # @return [Hash] Decode the full video and return a hash containing the frame count, fps, runtime, and the sizes of the decompressed video and audio streams.
  memoize def playback_info
    # https://ffmpeg.org/ffmpeg-filters.html#silencedetect
    # https://ffmpeg.org/ffmpeg-filters.html#ebur128-1
    # XXX `-c copy` is faster, but it doesn't decompress the stream so it can't detect corrupt videos.
    output, progress = Danbooru::Tempfile.create do |tempfile|
      output = shell!("ffmpeg -hide_banner -i #{file.path.shellescape} -progress #{tempfile.path} -af silencedetect=noise=0.0001:duration=0.25s,ebur128=metadata=1:dualmono=true:peak=true -f null /dev/null")
      [output, tempfile.read]
    end

    lines = output.split(/\r\n|\r|\n/)

    # ...
    # frame=10
    # out_time_ms=1000000
    # ...
    # progress=end
    time_info = progress.split(/(?=frame=)/).last.lines.to_h { |line| line.chomp.split("=", 2) }

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
end
