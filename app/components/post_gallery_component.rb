# frozen_string_literal: true
#
# A component that displays a gallery of post thumbnails.
#
# There are two types of galleries:
#
# * Grid galleries, where posts are arranged in a fixed grid.
# * Inline galleries, where posts are arranged on a single scrollable row, as
#   seen in parent/child post sets.
#
class PostGalleryComponent < ApplicationComponent
  # The default size of thumbnails in a gallery. See also PostPreviewComponent::DEFAULT_SIZE
  # for the default size of standalone thumbnails.
  DEFAULT_SIZE = "180"

  attr_reader :inline, :size, :options

  # The list of posts in the gallery.
  renders_many :posts, PostPreviewComponent

  # An optional footer that displays beneath the posts. Usually used for the paginator.
  renders_one :footer

  # @param inline [Boolean] If true, the gallery is rendered as a single row with a
  #   horizontal scrollbar. If false, the gallery is rendered as a grid of thumbnails.
  # @param size [String] The size of thumbnails in the gallery. Can be "150",
  #   "180", "225", "225w", "270", "270w", or "360".
  # @param options [Hash] A set of options given to the PostPreviewComponent.
  def initialize(inline: false, size: DEFAULT_SIZE, **options)
    super
    @inline = inline
    @options = options

    if size.to_s.in?(PostPreviewComponent::SIZES)
      @size = size
    else
      @size = DEFAULT_SIZE
    end
  end

  def gallery_type
    if inline
      :inline
    else
      :grid
    end
  end
end
