class PostPresenter
  attr_reader :pool, :next_post_in_pool
  delegate :tag_list_html, :split_tag_list_html, :split_tag_list_text, :inline_tag_list_html, to: :tag_set_presenter

  def self.preview(post, show_deleted: false, tags: "", **options)
    if post.nil?
      return "<em>none</em>".html_safe
    end

    if post.is_deleted? && !show_deleted
      return ""
    end

    if !post.visible?
      return ""
    end

    if post.is_ugoira? && !post.has_ugoira_webm?
      # ugoira preview gen is async so dont render it immediately
      return ""
    end

    locals = {}
    locals[:post] = post

    locals[:article_attrs] = {
      "id" => "post_#{post.id}",
      "class" => preview_class(post, **options).join(" ")
    }.merge(data_attributes(post))

    locals[:link_target] = options[:link_target] || post

    locals[:link_params] = {}
    if tags.present? && !CurrentUser.is_anonymous?
      locals[:link_params]["q"] = tags
    end
    if options[:pool_id]
      locals[:link_params]["pool_id"] = options[:pool_id]
    end
    if options[:favgroup_id]
      locals[:link_params]["favgroup_id"] = options[:favgroup_id]
    end

    locals[:tooltip] = "#{post.tag_string} rating:#{post.rating} score:#{post.score}"

    locals[:cropped_url] = if options[:show_cropped] && post.has_cropped? && !CurrentUser.user.disable_cropped_thumbnails?
      post.crop_file_url
    else
      post.preview_file_url
    end

    locals[:preview_url] = post.preview_file_url

    locals[:alt_text] = "post ##{post.id}"

    locals[:has_cropped] = post.has_cropped?

    if options[:pool]
      locals[:pool] = options[:pool]
    else
      locals[:pool] = nil
    end

    locals[:width] = post.image_width
    locals[:height] = post.image_height

    # XXX work around ancient bad posts with null or zero dimensions.
    if post.image_width.to_i > 0 && post.image_height.to_i > 0
      downscale_ratio = Danbooru.config.small_image_width.to_f / [post.image_width, post.image_height].max
      locals[:preview_width] = [(downscale_ratio * post.image_width).floor, post.image_width].min
      locals[:preview_height] = [(downscale_ratio * post.image_height).floor, post.image_height].min
    else
      locals[:preview_width] = 0
      locals[:preview_height] = 0
    end

    if options[:similarity]
      locals[:similarity] = options[:similarity].round(1)
    else
      locals[:similarity] = nil
    end

    if options[:size]
      locals[:size] = post.file_size
    else
      locals[:size] = nil
    end

    if options[:recommended]
      locals[:recommended] = options[:recommended].round(1)
    else
      locals[:recommended] = nil
    end

    ApplicationController.render(partial: "posts/partials/index/preview", locals: locals)
  end

  def self.preview_class(post, pool: nil, size: nil, similarity: nil, recommended: nil, compact: nil, **options)
    klass = ["post-preview"]
    # klass << " large-cropped" if post.has_cropped? && options[:show_cropped]
    klass << "captioned" if pool || size || similarity || recommended
    klass << "post-status-pending" if post.is_pending?
    klass << "post-status-flagged" if post.is_flagged?
    klass << "post-status-deleted" if post.is_deleted?
    klass << "post-status-has-parent" if post.parent_id
    klass << "post-status-has-children" if post.has_visible_children?
    klass << "post-preview-compact" if compact
    klass
  end

  def self.data_attributes(post)
    attributes = {
      "data-id" => post.id,
      "data-has-sound" => post.has_tag?('video_with_sound|flash_with_sound'),
      "data-tags" => post.tag_string,
      "data-pools" => post.pool_string,
      "data-approver-id" => post.approver_id,
      "data-rating" => post.rating,
      "data-large-width" => post.large_image_width,
      "data-large-height" => post.large_image_height,
      "data-width" => post.image_width,
      "data-height" => post.image_height,
      "data-flags" => post.status_flags,
      "data-parent-id" => post.parent_id,
      "data-has-children" => post.has_children?,
      "data-score" => post.score,
      "data-views" => post.view_count,
      "data-fav-count" => post.fav_count,
      "data-pixiv-id" => post.pixiv_id,
      "data-file-ext" => post.file_ext,
      "data-source" => post.source,
      "data-uploader-id" => post.uploader_id,
      "data-normalized-source" => post.normalized_source,
      "data-is-favorited" => post.favorited_by?(CurrentUser.user.id)
    }

    if post.visible?
      attributes["data-md5"] = post.md5
      attributes["data-file-url"] = post.file_url
      attributes["data-large-file-url"] = post.large_file_url
      attributes["data-preview-file-url"] = post.preview_file_url
    end

    attributes
  end

  def initialize(post)
    @post = post
  end

  def tag_set_presenter
    @tag_set_presenter ||= TagSetPresenter.new(@post.tag_array)
  end

  def humanized_essential_tag_string
    @humanized_essential_tag_string ||= tag_set_presenter.humanized_essential_tag_string(default: "##{@post.id}")
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
    return CurrentUser.user.enable_sequential_post_navigation
  end
end
