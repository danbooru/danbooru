class MediaFile::Ugoira < MediaFile
  def dimensions
    tempfile = Tempfile.new
    folder = Zip::File.new(file.path)
    folder.first.extract(tempfile.path) { true }

    image_file = MediaFile.open(tempfile)
    image_file.dimensions
  ensure
    image_file.close
    tempfile.close!
  end
end
