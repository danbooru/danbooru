# frozen_string_literal: true

class PostPresenter
  attr_reader :pool, :next_post_in_pool

  delegate :split_tag_list_text, to: :tag_set_presenter

  def initialize(post)
    @post = post
  end

  # @param tags_by_name [Hash<String, Tag>] Preloaded tags for the whole page, keyed by name.
  def tag_set_presenter(tags_by_name: nil)
    @tag_set_presenter ||= TagSetPresenter.new(@post.tag_array, tags_by_name:)
  end

  def humanized_essential_tag_string(tags_by_name: nil)
    @humanized_essential_tag_string ||= tag_set_presenter(tags_by_name:).humanized_essential_tag_string.presence || "##{@post.id}"
  end

  def filename_for_download(current_user)
    if current_user.disable_tagged_filenames?
      "#{@post.md5}.#{@post.file_ext}"
    else
      "#{humanized_essential_tag_string} - #{@post.md5}.#{@post.file_ext}"
    end
  end
end
