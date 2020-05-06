class MediaFile::Image < MediaFile
  def dimensions
    image.size
  end

  def image
    @image ||= Vips::Image.new_from_file(file.path)
  end
end
