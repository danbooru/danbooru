# frozen_string_literal: true

require "shellwords"

# A wrapper for the ffmpeg command.
class FFmpeg
  extend Memoist

  class Error < StandardError; end

  # The maximum number of packets in all streams combined. Reading the full metadata for each frame and packet uses
  # about 5KB of memory per frame, so this limits it to about 500MB. 100k packets is about 12 minutes of 60 FPS video
  # with audio.
  MAX_PACKET_COUNT = 100_000

  # The maximum width and height of video preview images. This is the size of the largest preview generated for videos.
  PREVIEW_SIZE = 720

  # The timeout for encoding a video. This is longer than the default command timeout, because two-pass VP9 encoding
  # of a 500-frame 1080p ugoira can take a minute or more.
  ENCODE_TIMEOUT = 5.minutes

  # The ffmpeg demuxers allowed for each file type. Broken APNGs are read as regular PNGs by image2.
  DEMUXERS = { mp4: "mov", avif: "mov", webm: "matroska", mkv: "matroska", gif: "gif", png: "apng,image2", webp: "image2", jpg: "image2" }.freeze

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
    #
    # The `scale=iw*sar:ih` corrects for a non-square pixel aspect ratio (PAR); it's a no-op when the PAR is 1:1
    # (the vast majority of videos). Without it, the preview would be generated from the raw coded frame, which
    # doesn't match the video's actual displayed dimensions when the PAR isn't square.
    #
    # The frames are scaled down to fit within 720x720 (the largest preview size) before `thumbnail`, because it keeps
    # 300 frames in memory to pick the best one. At full size, this would take several GB for a 4K video.
    filters = "scale=iw*sar:ih,scale=#{PREVIEW_SIZE}:#{PREVIEW_SIZE}:force_original_aspect_ratio=decrease:flags=lanczos,thumbnail=300"
    FFmpeg.shell!("ffmpeg #{input_args} -vf #{filters} -frames:v 1 -y #{vp.path.shellescape}")

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
    raise Error, "too many frames (max: #{MAX_PACKET_COUNT})" if packet_count > MAX_PACKET_COUNT

    output = FFmpeg.shell!("ffprobe -v quiet -print_format json -show_format -show_streams -show_packets -show_frames #{input_args}")
    output.parse_json || {}
  rescue Error => e
    { error: e.message.strip }.with_indifferent_access
  end

  # Count the packets in all streams without decoding the file or reading the metadata for each packet. This is fast
  # and uses little memory, even for files with millions of packets. This counts all streams, not just the largest one,
  # because the full metadata includes every stream, so a file with many streams could otherwise get around the limit.
  #
  # @return [Integer] The number of packets, or 0 if reading the file failed.
  memoize def packet_count
    output = FFmpeg.shell!("ffprobe -v quiet -count_packets -show_entries stream=nb_read_packets -print_format json #{input_args}")
    output.parse_json.to_h["streams"].to_a.sum { it["nb_read_packets"].to_i }
  rescue Error
    0
  end

  # The largest width and height of the frames in the first video stream, as they're displayed. The width is scaled by
  # the sample aspect ratio for anamorphic videos with non-square pixels.
  #
  # This comes from the decoded frames, not the container or stream metadata, because those can be changed to anything
  # without changing the actual video. It's the largest frame because videos can change resolution partway through.
  #
  # @return [Array<(Integer, Integer)>, nil] The width and height, or nil if there are no video frames.
  def display_dimensions
    frames = video_stream[:frames].to_a
    return nil if frames.empty?

    widths = frames.map do |frame|
      num, den = frame[:sample_aspect_ratio].to_s.split(":").map(&:to_i)
      sar = (num.to_i > 0 && den.to_i > 0) ? Rational(num, den) : 1
      (frame[:width].to_i * sar).round
    end

    [widths.max, frames.map { it[:height].to_i }.max]
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
    frame_count = video_streams.pluck(:frames).map(&:size).max

    frame_count || playback_info[:frame].to_i
  end

  # @return [Array<Integer>] The duration of each video frame in milliseconds. The durations may be different if the
  #   video has a variable frame rate. If there are multiple video streams, this will be the first stream, and if there
  #   are no video streams, this will be an empty array.
  memoize def frame_durations
    # video_stream[:frames].pluck(:duration) # XXX Duration is only available for .webm files, not .mp4
    video_stream[:frames].pluck(:best_effort_timestamp_time).push(duration).each_cons(2).map do |before, after|
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
    if video_stream.key?(:bit_rate)
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
    if audio_stream.key?(:bit_rate)
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
      output = FFmpeg.shell!("ffmpeg -hide_banner #{input_args} -progress #{tempfile.path} -af silencedetect=noise=0.0001:duration=0.25s,ebur128=metadata=1:dualmono=true:peak=true -f null /dev/null")
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
    size_info = size_line.scan(/[a-z ]+: *[a-z0-9]+/i).to_h do |pair|
      key, value = pair.split(/: */)
      [key.strip, value.to_i * 1000] # [" audio", "16kB"] => ["audio", 16000]
    end

    # [silencedetect @ 0x561855af1040] silence_start: -0.00133333e=N/A speed=  25x
    # [silencedetect @ 0x561855af1040] silence_end: 12.052 | silence_duration: 12.0533
    silence_info = lines.grep(/silence_duration/).map do |line|
      line.scan(/[a-z_]+: *[0-9.]+/i).to_h do |pair|
        key, value = pair.split(/: */)
        [key, value.to_f]
      end
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
      ebur128_lines = lines[ebur128_index..(ebur128_index + 13)].join("\n")
      ebur128_info = ebur128_lines.scan(/^ *[a-z ]+: *-?(?:inf|[0-9.]+) (?:LUFS|LU|dBFS)$/i).to_h do |pair|
        key, value = pair.split(/: */)
        value = -1000.0 if value == "-inf dBFS" # "Peak: -inf dBFS" for silent audio tracks.
        [key.strip.tr(" ", "_"), value.to_f] # ["LRA low", "-34.3 LUFS"] => ["lra_low", -34.3]
      end
    end

    { **time_info, **size_info, silence: silence_info, ebur128: ebur128_info.to_h }.with_indifferent_access
  rescue Error => e
    { error: e.message.strip }.with_indifferent_access
  end

  # The options for reading the input file.
  def input_args
    FFmpeg.input_args(file.path, FFmpeg.demuxers(file.file_ext))
  end

  # Encode a list of images as a video, with each image shown for the given duration.
  #
  # @param images [Array<MediaFile>] The images. They must all have the same file type and dimensions.
  # @param durations [Array<Integer>] How long to show each image, in milliseconds.
  # @param output_path [String] The file to write the video to.
  # @param width [Integer] The width of the output video. May be padded to an even number if the codec requires it.
  # @param height [Integer] The height of the output video. May be padded to an even number if the codec requires it.
  # @param format [Symbol] The video container format (:webm, :mkv, or :mp4). Default: :webm.
  # @param codec [Symbol] The video codec (:h264, :h265, :vp8, :vp9, or :av1). Default: h264 for mp4, vp9 for webm.
  # @param quality [Symbol] The quality preset (:high or :lossless). Default: :high.
  # @param pix_fmt [Symbol] The pixel format (:yuv420p, :yuva420p, :yuv420p10le, :yuv444p). Default: :yuv420p for JPEG images, :yuva420p for PNG/GIF images (to preserve transparency).
  # @param two_pass [Boolean] Whether to use two-pass encoding for vp8/vp9. Two-pass encoding is slower but higher quality. Default: true for vp8/vp9.
  # @param threads [Integer] The number of threads to use for encoding.
  def self.encode_images!(images, durations, output_path,
                          width: images.first.width,
                          height: images.first.height,
                          format: :webm,
                          codec: (format == :mp4) ? :h264 : :vp9,
                          quality: :high,
                          pix_fmt: (images.first.file_ext == :jpg) ? :yuv420p : :yuva420p,
                          two_pass: codec.in?(%i[vp8 vp9]),
                          threads: Danbooru.config.max_concurrency.to_i)
    codec = :h264 if codec == :avc
    codec = :h265 if codec == :hevc

    case format
    in :mp4
      raise "#{codec} is not supported by #{format}" if codec == :vp8

      # https://ffmpeg.org/ffmpeg-formats.html#Options-6
      # `+faststart` makes playback faster by moving metadata to the start of the file.
      # `-bf 0` disables B-frames, which makes compression less efficient but fixes an issue where `ffplay` reports incorrect
      #   playback durations and where `ffprobe -show_frames` doesn't return frame durations. XXX Should remove this
      format_args = "-f mp4 -movflags +faststart -bf 0"

    in :webm
      raise "#{codec} is not supported by #{format}" unless codec.in?(%i[vp8 vp9 av1])
      format_args = "-f webm -cues_to_front 1"
      format_args += " -auto-alt-ref 0" if codec == :vp8 && pix_fmt == :yuva420p # Can't use yuva420p with vp8 if auto-alt-ref is enabled

    in :mkv
      format_args = "-f matroska -cues_to_front 1"

    else
      raise "unsupported format: #{format}"
    end

    case [codec, quality]
    # https://trac.ffmpeg.org/wiki/Encode/H.264
    in :h264, :high
      codec_args = "-codec:v libx264 -preset medium -tune animation -crf 18"
    in :h264, :lossless
      codec_args = "-codec:v libx264 -preset medium -tune animation -crf 0 -qp 0"

    # https://trac.ffmpeg.org/wiki/Encode/H.265
    in :h265, :high
      codec_args = "-codec:v libx265 -preset medium -crf 24"
    in :h265, :lossless
      codec_args = "-codec:v libx265 -preset medium -x265-params lossless=1"

    # https://trac.ffmpeg.org/wiki/Encode/VP8
    # https://ffmpeg.org/ffmpeg-codecs.html#libvpx
    # https://www.webmproject.org/docs/encoder-parameters/
    in :vp8, :high
      # XXX `-b:v 0` is broken, set a high max bitrate instead (https://trac.ffmpeg.org/ticket/9718)
      codec_args = "-codec:v libvpx -cpu-used 1 -crf 12 -b:v 1000M"
    in :vp8, :lossless
      raise NotImplementedError, "lossless encoding is not supported for VP8"

    # https://trac.ffmpeg.org/wiki/Encode/VP9
    # https://wiki.webmproject.org/ffmpeg/vp9-encoding-guide
    # https://developers.google.com/media/vp9/settings/vod
    in :vp9, :high
      codec_args = "-codec:v libvpx-vp9 -cpu-used 1 -row-mt 1 -tile-columns 2 -tile-rows 1 -crf 12 -b:v 0"
    in :vp9, :lossless
      codec_args = "-codec:v libvpx-vp9 -cpu-used 1 -row-mt 1 -tile-columns 2 -tile-rows 1 -lossless 1"

    # https://trac.ffmpeg.org/wiki/Encode/AV1
    # https://ffmpeg.org/ffmpeg-codecs.html#libsvtav1
    # https://academysoftwarefoundation.github.io/EncodingGuidelines/EncodeAv1.html
    in :av1, :high
      codec_args = "-codec:v libsvtav1"
    in :av1, :lossless
      raise NotImplementedError, "lossless encoding is not supported for libsvt AV1"

    else
      raise "unsupported codec: #{codec}"
    end

    raise "two-pass encoding is not supported for #{codec}" if two_pass && !codec.in?(%i[vp8 vp9])

    # https://ffmpeg.org/ffmpeg-filters.html#scale
    scale_filter = "scale='#{width}:#{height}:flags=lanczos'" if [width, height] != [images.first.width, images.first.height]

    # h264/h265 with 4:2:0 subsampling requires the dimensions to be even. Pad to even dimensions by duplicating the edge pixels.
    # XXX av1 has a minimum required size of 64x64
    # https://ffmpeg.org/ffmpeg-filters.html#pad-1
    # https://ffmpeg.org/ffmpeg-filters.html#fillborders
    if (width.odd? || height.odd?) && codec.in?(%i[h264 h265 av1]) && pix_fmt.to_s.include?("420")
      pad_filter = "pad='iw+mod(iw,2):ih+mod(ih,2)',fillborders='right=#{width % 2}:bottom=#{height % 2}:mode=smear'"
    end

    filters = ["null", scale_filter, pad_filter].compact.join(",")

    Danbooru::Tempdir.create(["danbooru-ffmpeg-"]) do |tmpdir|
      input_args = concat_input_args(images.zip(durations), File.join(tmpdir.path, "files.txt"))

      # `-xerror` makes ffmpeg fail if an image can't be read, instead of silently stopping at that image.
      ffmpeg_command = %{ffmpeg -loglevel 99 -xerror #{input_args} -enc_time_base 1/1000 -video_track_timescale 1000 -fps_mode:v vfr -vf "#{filters}" #{codec_args} #{format_args} -pix_fmt #{pix_fmt} -threads #{threads} -an}

      encoded_output_path = File.join(tmpdir.path, "out.#{format}")
      if two_pass
        passlogfile_path = File.join(tmpdir.path, "ffmpeg2pass")
        shell!("#{ffmpeg_command} -pass 1 -passlogfile #{passlogfile_path.shellescape} -f null /dev/null")
        shell!("#{ffmpeg_command} -pass 2 -passlogfile #{passlogfile_path.shellescape} -y #{encoded_output_path.shellescape}", timeout: ENCODE_TIMEOUT)
      else
        shell!("#{ffmpeg_command} -y #{encoded_output_path.shellescape}", timeout: ENCODE_TIMEOUT)
      end

      # XXX ffmpeg incorrectly sets the duration of the last frame to 40ms, so here we use mkvmerge to fix it.
      # https://man.archlinux.org/man/mkvmerge.1.en#Timestamp_file_format_v2
      timestamps_txt_path = File.join(tmpdir.path, "timestamps.txt")
      timestamps = (0..durations.size).map { durations[0...it].sum }
      File.write(timestamps_txt_path, "# timestamp format v2\n#{timestamps.join("\n")}\n")

      if format == :mp4
        # mkvmerge can read .mp4 files, but it can only output .mkv files, so we have to convert the fixed .mkv back to .mp4
        fixed_output_path = File.join(tmpdir.path, "out-fixed.mkv")
        shell!("mkvmerge --timestamps 0:#{timestamps_txt_path.shellescape} #{encoded_output_path.shellescape} -o #{fixed_output_path.shellescape}")
        shell!("ffmpeg #{input_args(fixed_output_path, demuxers(:mkv))} -c copy #{format_args} -y #{output_path.shellescape}")
      else
        shell!("mkvmerge --timestamps 0:#{timestamps_txt_path.shellescape} #{encoded_output_path.shellescape} -o #{output_path.shellescape}")
      end
    end
  end

  # The options for reading an input file. Only local files and the given demuxers are allowed, so a file can't pretend
  # to be a playlist that makes ffmpeg read other files or URLs.
  #
  # @param path [String] The input file.
  # @param demuxers [String] A comma-separated list of the demuxers allowed to read the file.
  def self.input_args(path, demuxers)
    "-protocol_whitelist file -format_whitelist #{demuxers} -i #{path.shellescape}"
  end

  # The options for reading a list of images as a video, with each image shown for the given duration. Each image can
  # only be read by the demuxers for its file type, so an image can't be another playlist.
  #
  # @see https://ffmpeg.org/ffmpeg-formats.html#concat-1
  # @param frames [Array<(MediaFile, Integer)>] The images and their durations in milliseconds.
  # @param playlist_path [String] The path to write the concat playlist to.
  def self.concat_input_args(frames, playlist_path)
    # https://www.ffmpeg.org/ffmpeg-utils.html#Quoting-and-escaping
    #
    # XXX The concat demuxer rounds frames to the nearest 40ms (https://trac.ffmpeg.org/ticket/9210). To work around
    # this, we multiply by 40 then use `-itsscale 0.025` to divide by 40 and get back the correct duration.
    playlist = frames.map do |frame, duration|
      "file '#{frame.path.gsub("'", "'\\\\''")}'\noption format_whitelist #{demuxers(frame.file_ext)}\nduration #{duration * 40}ms\n"
    end

    File.write(playlist_path, playlist.join)

    "-itsscale 0.025 -f concat -safe 0 #{input_args(playlist_path, "concat")}"
  end

  private_class_method :concat_input_args

  # @param file_ext [Symbol] The file type.
  # @return [String] The demuxers allowed to read files of the given type.
  def self.demuxers(file_ext)
    DEMUXERS.fetch(file_ext) { raise Error, "unsupported file type: #{file_ext}" }
  end

  def self.shell!(command, **options)
    program = command.shellsplit.first
    output, status = ExternalCommand.run(command, **options)

    if !status.success?
      errors = output.split(/\r?\n/).grep(/^(Error|\[\w+ @ 0x\h+\])/).uniq.join("\n")
      raise Error, "#{program} failed: #{errors}"
    end

    output.force_encoding("ASCII-8BIT")
  rescue ExternalCommand::TimeoutError => e
    raise Error, e.message
  end
end
