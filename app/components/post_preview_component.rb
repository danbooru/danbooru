# frozen_string_literal: true

class PostPreviewComponent < ApplicationComponent
  DEFAULT_SIZE = "150"

  SIZES = %w[150 180 225 225w 270 270w 360]

  with_collection_parameter :post

  attr_reader :post, :tags, :size, :show_deleted, :link_target, :pool, :similarity, :recommended, :show_votes, :fit, :show_size, :save_data, :current_user, :options

  delegate :external_link_to, :time_ago_in_words_tagged, :duration_to_hhmmss, :render_post_votes, :empty_heart_icon, :sound_icon, to: :helpers
  delegate :image_width, :image_height, :file_ext, :file_size, :duration, :is_animated?, to: :media_asset
  delegate :media_asset, to: :post

  # @param post [Post] The post to show the thumbnail for.
  # @param tags [String] The current tag search, if any.
  # @param size [String] The size of the thumbnail. One of "150", "180", "225",
  #   "225w", "270", "270w", or "360".
  # @param show_deleted [Boolean] If true, show thumbnails for deleted posts.
  #   If false, hide thumbnails of deleted posts.
  # @param show_votes [Boolean] If true, show scores and vote buttons beneath the thumbnail.
  # @param show_size [Boolean] If true, show filesize and resolution beneath the thumbnail.
  # @param save_data [Boolean] If true, save data by not serving higher quality thumbnails
  #   on 2x pixel density displays. Default: false.
  # @param link_target [ApplicationRecord] What the thumbnail links to (default: the post).
  # @param current_user [User] The current user.
  # @param fit [Symbol] If `:fixed`, make the thumbnail container a fixed size
  #   (e.g. 180x180), even if the thumbnail image is smaller than that. If `:compact`,
  #   make the thumbnail container shrink to the same size as the thumbnail image.
  def initialize(post:, tags: "", size: DEFAULT_SIZE, show_deleted: false, show_votes: false, link_target: post, pool: nil, similarity: nil, recommended: nil, show_size: nil, save_data: CurrentUser.save_data, fit: :compact, current_user: CurrentUser.user, **options)
    super
    @post = post
    @tags = tags.presence
    @size = size.presence || DEFAULT_SIZE
    @show_deleted = show_deleted
    @show_votes = show_votes
    @link_target = link_target
    @pool = pool
    @similarity = similarity.round(1) if similarity.present?
    @recommended = recommended
    @fit = fit
    @show_size = show_size
    @save_data = save_data
    @current_user = current_user
    @options = options
  end

  def render?
    post.present? && post.visible?(current_user) && (!post.is_deleted? || show_deleted)
  end

  def article_attrs(classes = nil)
    { class: [classes, *preview_class].compact.join(" "), **data_attributes }
  end

  def variant
    case size
    when "150"
      media_asset.variant("preview")
    when "180"
      media_asset.variant("180x180")
    when "225", "225w"
      media_asset.variant("360x360")
    when "270", "270w"
      media_asset.variant("360x360")
    when "360"
      media_asset.variant("360x360")
    else
      raise NotImplementedError
    end
  end

  def tooltip
    "#{post.tag_string} rating:#{post.rating} score:#{post.score}"
  end

  def preview_class
    klass = ["post-preview"]
    klass << "captioned" if pool || show_size || similarity || recommended
    klass << "post-status-pending" if post.is_pending?
    klass << "post-status-flagged" if post.is_flagged?
    klass << "post-status-deleted" if post.is_deleted?
    klass << "post-status-has-parent" if post.parent_id
    klass << "post-status-has-children" if post.has_visible_children?
    klass << "post-preview-show-votes" if show_votes
    klass << "post-preview-fit-#{fit}"
    klass << "post-preview-#{size}"
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
