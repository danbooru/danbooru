class MediaFile::Flash < MediaFile::Image
  def dimensions
    image_size = ImageSpec.new(file.path)
    [image_size.width, image_size.height]
  end
end
