# A component that displays a gallery of post thumbnails.
#
# There are three types of galleries:
#
# * Paginated galleries, as seen on the post index page and pool show page.
# * Unpaginated galleries, as seen on wiki pages, artist pages, and user profiles.
# * Inline galleries that fit on a single row, as seen in parent/child post sets.
#
class PostGalleryComponent < ApplicationComponent
  attr_reader :posts, :current_user, :inline, :options

  delegate :post_preview, :numbered_paginator, to: :helpers

  # A gallery can optionally have a footer that displays between the posts and the paginator.
  renders_one :footer

  # @param posts [Array<Post>, ActiveRecord::Relation<Post>] The set of posts to display
  # @param current_user [User] The current user.
  # @param inline [Boolean] If true, the gallery is rendered as a single row with a
  #   horizontal scrollbar. If false, the gallery is rendered as a grid of thumbnails.
  # @param options [Hash] A set of options given to the thumbnail in `post_preview`.
  def initialize(posts:, current_user:, inline: false, **options)
    super
    @posts = posts
    @posts = @posts.includes(:media_asset) if posts.is_a?(ActiveRecord::Relation)
    @current_user = current_user
    @inline = inline
    @options = options
  end

  def gallery_type
    if inline
      :inline
    elsif has_paginator?
      :paginated
    else
      :unpaginated
    end
  end

  def has_paginator?
    posts.respond_to?(:total_count)
  end

  def total_count
    if has_paginator?
      posts.total_count
    else
      posts.length
    end
  end

  def empty?
    total_count == 0
  end
end
