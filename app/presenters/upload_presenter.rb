class UploadPresenter < Presenter
  attr_reader :upload
  delegate :inline_tag_list_html, to: :tag_set_presenter

  def initialize(upload)
    @upload = upload
  end

  def tag_set_presenter
    @tag_set_presenter ||= TagSetPresenter.new(upload.tag_string.split)
  end
end
