class MediaFile::Video < MediaFile
  def dimensions
    [video.width, video.height]
  end

  def video
    @video ||= FFMPEG::Movie.new(file.path)
  end
end
