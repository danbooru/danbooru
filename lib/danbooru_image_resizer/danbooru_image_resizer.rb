require 'danbooru_image_resizer/danbooru_image_resizer.so'

module Danbooru
  def resize(file_ext, read_path, write_path, output_size, output_quality)
    Danbooru.resize_image(file_ext, read_path, write_path, output_size[:width], output_size[:height], output_quality)
  end

  def reduce_to(size, max_size)
    size.dup.tap do |new_size|
      if new_size[:width] > max_size[:width]
        scale = max_size[:width].to_f / new_size[:width].to_f
        new_size[:width] = new_size[:width] * scale
        new_size[:height] = new_size[:height] * scale
      end

      if max_size[:height] && (new_size[:height] > max_size[:height])
        scale = max_size[:height].to_f / new_size[:height].to_f
        new_size[:width] = new_size[:width] * scale
        new_size[:height] = new_size[:height] * scale
      end
    
      new_size[:width] = new_size[:width].to_i
      new_size[:height] = new_size[:height].to_i
    end
  end

  module_function :resize
  module_function :reduce_to
end
