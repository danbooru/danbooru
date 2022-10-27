# frozen_string_literal: true

# A MediaFile for a webm or mp4 video. Uses ffmpeg to generate preview
# thumbnails.
#
# @see https://github.com/streamio/streamio-ffmpeg
class MediaFile::Video < MediaFile
  delegate :duration, :frame_count, :frame_rate, :has_audio?, :video_codec, :video_stream, :video_streams, :audio_streams, to: :video

  def dimensions
    [video.width, video.height]
  end

  def preview!(max_width, max_height, **options)
    preview_frame.preview!(max_width, max_height, **options)
  end

  def is_supported?
    return false if video_streams.size != 1
    return false if audio_streams.size > 1
    return false if is_webm? && metadata["Matroska:DocType"] != "webm"
    return false if is_mp4? && !video_codec.in?(["h264", "vp9"])

    true
  end

  # True if decoding the video fails.
  def is_corrupt?
    video.playback_info.blank?
  end

  private

  def video
    FFmpeg.new(file)
  end

  def preview_frame
    video.smart_video_preview
  end

  memoize :video, :preview_frame, :dimensions, :duration, :has_audio?
end
