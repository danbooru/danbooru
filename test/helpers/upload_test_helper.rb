module UploadTestHelper
  def upload_file(path, content_type, filename)
    tempfile = Tempfile.new(filename)
    FileUtils.copy_file(path, tempfile.path)

    (class << tempfile; self; end).class_eval do
      alias local_path path
      define_method(:tempfile) {self}
      define_method(:original_filename) {filename}
      define_method(:content_type) {content_type}
    end

    tempfile
  end

  def upload_jpeg(path)
    upload_file(path, "image/jpeg", File.basename(path))
  end

  def upload_zip(path)
    upload_file(path, "application/zip", File.basename(path))
  end
end
