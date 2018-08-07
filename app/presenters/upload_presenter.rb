class UploadPresenter < Presenter
  def initialize(upload)
    @upload = upload
  end

  def status(template)
    case @upload.status
    when /duplicate: (\d+)/
      dup_post_id = $1
      template.link_to(@upload.status.gsub(/error: RuntimeError - /, ""), template.__send__(:post_path, dup_post_id))

    when /\Aerror: /
      @upload.status.gsub(/DETAIL:.+/m, "...")

    else
      @upload.status
    end
  end
end
