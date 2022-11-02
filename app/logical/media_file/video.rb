# frozen_string_literal: true

# A MediaFile for a webm or mp4 video. Uses ffmpeg to generate preview
# thumbnails.
#
# @see https://github.com/streamio/streamio-ffmpeg
class MediaFile::Video < MediaFile
  delegate :duration, :frame_count, :frame_rate, :has_audio?, :is_corrupt?, :pix_fmt, :video_codec, :video_stream, :video_streams, :audio_streams, :error, to: :video

  def dimensions
    [video.width, video.height]
  end

  def preview!(max_width, max_height, **options)
    preview_frame.preview!(max_width, max_height, **options)
  end

  def metadata
    super.merge({ "FFmpeg:Error" => error }.compact_blank)
  end

  def is_supported?
    return false if video_streams.size != 1
    return false if audio_streams.size > 1
    return false if is_webm? && exif_metadata["Matroska:DocType"] != "webm"
    return false if is_mp4? && !video_codec.in?(["h264", "vp9"])

    # Only allow pixel formats supported by most browsers. Don't allow 10-bit video or 4:4:4 subsampling (neither are supported by Firefox).
    #
    # yuv420p:  8-bit YUV, 4:2:0 subsampling. The vast majority of videos use this format.
    # yuvj420p: 8-bit YUV, 4:2:0 subsampling, color range restricted to 16-235. Uncommon, but widely supported.
    # yuv444p:  8-bit YUV, 4:4:4 subsampling (i.e. no subsampling). Uncommon, not supported by Firefox.
    # yuv420p10le: 10-bit YUV, 4:2:0 subsampling (i.e. 10-bit video). Uncommon, not supported by Firefox.
    # gbrp: 8-bit RGB (used by VP9). Uncommon, but widely supported.
    #
    # https://github.com/FFmpeg/FFmpeg/blob/master/libavutil/pixfmt.h
    return false if !pix_fmt.in?(%w[yuv420p yuvj420p gbrp])

    true
  end

  private

  def video
    FFmpeg.new(file)
  end

  def preview_frame
    video.smart_video_preview
  end

  memoize :video, :preview_frame, :dimensions, :metadata, :duration, :has_audio?
end
