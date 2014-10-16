class PixivUgoiraService
  attr_reader :width, :height, :frame_data, :content_type

  def process(post)
    save_frame_data(post)
  end

  def save_frame_data(post)
    PixivUgoiraFrameData.create(:data => @frame_data, :content_type => @content_type, :post_id => post.id)
  end

  def generate_resizes(source_path, output_path, preview_path)
    PixivUgoiraConverter.new.convert(source_path, output_path, preview_path, @frame_data)
  end

  def load(data)
    @frame_data = data[:ugoira_frame_data]
    @width = data[:ugoira_width]
    @height = data[:ugoira_height]
    @content_type = data[:ugoira_content_type]
  end
end
