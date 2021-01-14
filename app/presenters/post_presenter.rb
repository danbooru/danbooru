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

  def has_nav_links?(template)
    has_sequential_navigation?(template.params) || @post.pools.undeleted.any? || CurrentUser.favorite_groups.for_post(@post.id).any?
  end

  def has_sequential_navigation?(params)
    return false if PostQueryBuilder.new(params[:q]).has_metatag?(:order, :ordfav, :ordpool)
    return false if params[:pool_id].present? || params[:favgroup_id].present?
    true
  end
end
