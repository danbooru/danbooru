# frozen_string_literal: true

class PostPreviewComponent < ApplicationComponent
  with_collection_parameter :post

  attr_reader :post, :tags, :show_deleted, :show_cropped, :link_target, :pool, :similarity, :recommended, :compact, :size, :current_user, :options

  delegate :external_link_to, :time_ago_in_words_tagged, :duration_to_hhmmss, :empty_heart_icon, :sound_icon, to: :helpers
  delegate :image_width, :image_height, :file_ext, :file_size, :duration, :is_animated?, to: :media_asset
  delegate :media_asset, to: :post

  def initialize(post:, tags: "", show_deleted: false, show_cropped: true, link_target: post, pool: nil, similarity: nil, recommended: nil, compact: nil, size: nil, current_user: CurrentUser.user, **options)
    super
    @post = post
    @tags = tags.presence
    @show_deleted = show_deleted
    @show_cropped = show_cropped
    @link_target = link_target
    @pool = pool
    @similarity = similarity.round(1) if similarity.present?
    @recommended = recommended.round(1) if recommended.present?
    @compact = compact
    @size = post.file_size if size.present?
    @current_user = current_user
    @options = options
  end

  def render?
    post.present? && post.visible?(current_user) && (!post.is_deleted? || show_deleted)
  end

  def article_attrs(classes = nil)
    { class: [classes, *preview_class].compact.join(" "), **data_attributes }
  end

  def cropped_url
    if show_cropped && post.has_cropped? && !current_user.disable_cropped_thumbnails?
      post.crop_file_url
    else
      post.preview_file_url
    end
  end

  def preview_dimensions
    downscale_ratio = Danbooru.config.small_image_width.to_f / [post.image_width, post.image_height].max

    {
      width: [(downscale_ratio * post.image_width).floor, post.image_width].min,
      height: [(downscale_ratio * post.image_height).floor, post.image_height].min,
    }
  end

  def tooltip
    "#{post.tag_string} rating:#{post.rating} score:#{post.score}"
  end

  def preview_class
    klass = ["post-preview"]
    klass << "captioned" if pool || size || similarity || recommended
    klass << "post-status-pending" if post.is_pending?
    klass << "post-status-flagged" if post.is_flagged?
    klass << "post-status-deleted" if post.is_deleted?
    klass << "post-status-has-parent" if post.parent_id
    klass << "post-status-has-children" if post.has_visible_children?
    klass << "post-preview-compact" if compact
    klass
  end

  def data_attributes
    attributes = {
      "data-id" => post.id,
      "data-has-sound" => has_sound?,
      "data-tags" => post.tag_string,
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
      "data-fav-count" => post.fav_count,
      "data-pixiv-id" => post.pixiv_id,
      "data-file-ext" => post.file_ext,
      "data-source" => post.source,
      "data-uploader-id" => post.uploader_id,
      "data-normalized-source" => post.normalized_source,
    }

    if post.visible?(current_user)
      attributes["data-md5"] = post.md5
      attributes["data-file-url"] = post.file_url
      attributes["data-large-file-url"] = post.large_file_url
      attributes["data-preview-file-url"] = post.preview_file_url
    end

    attributes
  end

  def has_sound?
    post.has_tag?("sound")
  end
end
