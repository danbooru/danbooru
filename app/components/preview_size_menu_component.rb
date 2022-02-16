# frozen_string_literal: true

# The dropdown menu for selecting the thumbnail size. Used on the post index
# page, the upload index page, and the media assets index page.
class PreviewSizeMenuComponent < ApplicationComponent
  attr_reader :current_size

  def initialize(current_size:)
    @current_size = current_size.to_i
  end
end
