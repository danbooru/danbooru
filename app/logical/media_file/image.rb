class MediaFile::Image < MediaFile
  def dimensions
    image_size = ImageSpec.new(file.path)
    [image_size.width, image_size.height]
  end
end
