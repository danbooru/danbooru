module Danbooru
  def resize_image(extension, original_path, destination_path, width, height, quality)
    require 'mini_magick'
    image = MiniMagick::Image.open(original_path)
    image.resize "#{width}x#{height}"
    image.format extension
    image.write destination_path
  end

  module_function :resize_image
end
