module UploadTestHelper
  def upload_from_file(filepath)
    UploadService.new(file: upload_file(filepath)).start!
  end

  def upload_file(path)
    file = Tempfile.new(binmode: true)
    IO.copy_stream("#{Rails.root}/#{path}", file.path)
    uploaded_file = ActionDispatch::Http::UploadedFile.new(tempfile: file, filename: File.basename(path))

    yield uploaded_file if block_given?
    uploaded_file
  end
end
