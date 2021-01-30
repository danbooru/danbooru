class PostPresenter
  attr_reader :pool, :next_post_in_pool
  delegate :tag_list_html, :split_tag_list_html, :split_tag_list_text, :inline_tag_list_html, to: :tag_set_presenter

  def initialize(post)
    @post = post
  end

  def tag_set_presenter
    @tag_set_presenter ||= TagSetPresenter.new(@post.tag_array)
  end

  def humanized_essential_tag_string
    @humanized_essential_tag_string ||= tag_set_presenter.humanized_essential_tag_string.presence || "##{@post.id}"
  end

  def filename_for_download
    "#{humanized_essential_tag_string} - #{@post.md5}.#{@post.file_ext}"
  end
end
