class UploadPresenter < Presenter
  def initialize(upload)
    @upload = upload
  end
  
  def status(template)
    case @upload.status
    when /duplicate: (\d+)/
      template.link_to(@upload.status, template.__send__(:post_path, $1))
      
    else
      @upload.status
    end
  end
end
