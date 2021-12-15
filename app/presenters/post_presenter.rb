# frozen_string_literal: true

class PostPresenter
  attr_reader :pool, :next_post_in_pool

  delegate :split_tag_list_text, to: :tag_set_presenter

  def initialize(post)
    @post = post
  end

  def tag_set_presenter
    @tag_set_presenter ||= TagSetPresenter.new(@post.tag_array)
  end

  def humanized_essential_tag_string
    @humanized_essential_tag_string ||= tag_set_presenter.humanized_essential_tag_string.presence || "##{@post.id}"
  end

  def filename_for_download(current_user)
    if current_user.disable_tagged_filenames?
      "#{@post.md5}.#{@post.file_ext}"
    else
      "#{humanized_essential_tag_string} - #{@post.md5}.#{@post.file_ext}"
    end
  end
end
