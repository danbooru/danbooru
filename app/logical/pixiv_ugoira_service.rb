class PixivUgoiraService
  attr_reader :width, :height, :frame_data

  def process(post)
    save_frame_data(post)
  end

  def save_frame_data(post)
    PixivUgoiraFrameData.create(:data => @frame_data, :post_id => post.id)
  end

  def generate_resizes(source_path, output_path, preview_path)
    PixivUgoiraConverter.new.convert(source_path, output_path, preview_path, @frame_data)
  end

  def load(data)
    @frame_data = data[:ugoira_frame_data]
    @width = data[:ugoira_width]
    @height = data[:ugoira_height]
  end
end
