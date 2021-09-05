# A MediaFile for a webm or mp4 video. Uses ffmpeg to generate preview
# thumbnails.
#
# @see https://github.com/streamio/streamio-ffmpeg
class MediaFile::Video < MediaFile
  def dimensions
    [video.width, video.height]
  end

  def duration
    video.duration
  end

  def preview(max_width, max_height)
    preview_frame.preview(max_width, max_height)
  end

  def crop(max_width, max_height)
    preview_frame.crop(max_width, max_height)
  end

  def has_audio?
    video.audio_channels.present?
  end

  private

  def video
    raise NotImplementedError, "can't process videos: ffmpeg or mkvmerge not installed" unless self.class.videos_enabled?

    FFMPEG::Movie.new(file.path)
  end

  def preview_frame
    FFmpeg.new(file).smart_video_preview
  end

  memoize :video, :preview_frame, :dimensions, :duration, :has_audio?
end
