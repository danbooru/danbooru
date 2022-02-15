# frozen_string_literal: true

class MediaAssetGalleryComponent < ApplicationComponent
  DEFAULT_SIZE = 180

  attr_reader :inline, :size, :classes

  renders_many :media_assets
  renders_one :footer

  def initialize(inline: false, size: DEFAULT_SIZE, classes: [])
    super
    @inline = inline
    @size = size
    @classes = classes
  end
end
