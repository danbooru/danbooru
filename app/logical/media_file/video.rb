# frozen_string_literal: true

# A MediaFile for a webm or mp4 video. Uses ffmpeg to generate preview
# thumbnails.
#
# @see https://github.com/streamio/streamio-ffmpeg
class MediaFile::Video < MediaFile
  delegate :duration, :frame_count, :frame_rate, :has_audio?, :is_corrupt?, :major_brand, :pix_fmt,
    :video_codec, :video_bit_rate, :video_stream, :video_streams, :audio_codec, :audio_bit_rate,
    :audio_stream, :audio_streams, :silence_duration, :silence_percentage, :average_loudness,
    :peak_loudness, :loudness_range, :error, to: :video

  def close
    super
    @preview_frame&.close
  end

  def dimensions
    [video.width, video.height]
  end

  def preview!(max_width, max_height, **options)
    preview_frame.preview!(max_width, max_height, **options)
  end

  def metadata
    super.merge({
      "FFmpeg:Error" => error,
      "FFmpeg:MajorBrand" => major_brand,
      "FFmpeg:PixFmt" => pix_fmt,
      "FFmpeg:FrameCount" => frame_count,
      "FFmpeg:VideoCodec" => video_codec,
      "FFmpeg:VideoProfile" => video_stream[:profile],
      "FFmpeg:VideoBitRate" => video_bit_rate,
      "FFmpeg:AudioCodec" => audio_codec,
      "FFmpeg:AudioProfile" => audio_stream[:profile],
      "FFmpeg:AudioLayout" => audio_stream[:channel_layout],
      "FFmpeg:AudioBitRate" => audio_bit_rate,
      "FFmpeg:AudioPeakLoudness" => peak_loudness,
      "FFmpeg:AudioAverageLoudness" => average_loudness,
      "FFmpeg:AudioLoudnessRange" => loudness_range,
      "FFmpeg:AudioSilencePercentage" => silence_percentage,
    }.compact_blank)
  end

  def is_supported?
    return false if video_streams.size != 1
    return false if audio_streams.size > 1
    return false if is_webm? && exif_metadata["Matroska:DocType"] != "webm"
    return false if is_webm? && !video_codec.in?(%w[vp8 vp9 av1])
    return false if is_mp4? && !video_codec.in?(%w[h264 hevc vp9 av1])
    return false if has_audio? && is_webm? && !audio_codec.in?(%w[opus vorbis])
    return false if has_audio? && is_mp4? && !audio_codec.in?(%w[aac mp3 opus])

    # Only allow pixel formats supported by most browsers. Don't allow 10-bit video or 4:4:4 subsampling (neither are supported by Firefox).
    #
    # yuv420p:  8-bit YUV, 4:2:0 subsampling. The vast majority of videos use this format.
    # yuvj420p: 8-bit YUV, 4:2:0 subsampling, color range restricted to 16-235. Uncommon, but widely supported.
    # yuv444p:  8-bit YUV, 4:4:4 subsampling (i.e. no subsampling). Uncommon, not supported by Firefox.
    # yuv420p10le: 10-bit YUV, 4:2:0 subsampling (i.e. 10-bit video). Uncommon, not supported by Firefox.
    # gbrp: 8-bit RGB (used by VP9). Uncommon, but widely supported.
    #
    # https://github.com/FFmpeg/FFmpeg/blob/master/libavutil/pixfmt.h
    return false if pix_fmt.present? && !pix_fmt.in?(%w[yuv420p yuvj420p gbrp])

    true
  end

  private

  def video
    FFmpeg.new(self)
  end

  def preview_frame
    @preview_frame ||= video.smart_video_preview!
  end

  memoize :video, :dimensions, :metadata, :duration, :has_audio?
end
