require 'danbooru_image_resizer/danbooru_image_resizer.so'

module Danbooru
  def resize(file_ext, read_path, write_path, output_size, output_quality)
    Danbooru.resize_image(file_ext, read_path, write_path, output_size[:width], output_size[:height], output_quality)
  end

  def reduce_to(size, max_size, ratio = 1)
    ret = size.dup
    
    if ret[:width] > ratio * max_size[:width]
      scale = max_size[:width].to_f / ret[:width].to_f
      ret[:width] = ret[:width] * scale
      ret[:height] = ret[:height] * scale
    end

    if max_size[:height] && (ret[:height] > ratio * max_size[:height])
      scale = max_size[:height].to_f / ret[:height].to_f
      ret[:width] = ret[:width] * scale
      ret[:height] = ret[:height] * scale
    end
    
    ret[:width] = ret[:width].to_i
    ret[:height] = ret[:height].to_i
    ret
  end

  module_function :resize
  module_function :reduce_to
end
