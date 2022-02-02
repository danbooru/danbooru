# frozen_string_literal: true

class MediaAssetGalleryComponent < ApplicationComponent
  DEFAULT_SIZE = 180

  attr_reader :inline, :size, :options

  renders_many :media_assets, MediaAssetPreviewComponent
  renders_one :footer

  def initialize(inline: false, size: DEFAULT_SIZE, **options)
    super
    @inline = inline
    @size = size
    @option = options
  end
end
