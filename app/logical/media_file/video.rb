# A MediaFile for a webm or mp4 video. Uses ffmpeg to generate preview
# thumbnails.
#
# @see https://github.com/streamio/streamio-ffmpeg
class MediaFile::Video < MediaFile
  delegate :duration, :has_audio?, to: :video

  def dimensions
    [video.width, video.height]
  end

  def preview(max_width, max_height)
    preview_frame.preview(max_width, max_height)
  end

  def crop(max_width, max_height)
    preview_frame.crop(max_width, max_height)
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
