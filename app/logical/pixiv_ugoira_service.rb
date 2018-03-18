class PixivUgoiraService
  attr_reader :width, :height, :frame_data, :content_type

  def save_frame_data(post)
    PixivUgoiraFrameData.create(:data => @frame_data, :content_type => @content_type, :post_id => post.id)
  end

  def calculate_dimensions(source_path)
    folder = Zip::File.new(source_path)
    tempfile = Tempfile.new("ugoira-dimensions")

    begin
      folder.first.extract(tempfile.path) {true}
      image_size = ImageSpec.new(tempfile.path)
      @width = image_size.width
      @height = image_size.height
    ensure
      tempfile.close
      tempfile.unlink
    end
  end

  def load(data)
    if data[:is_ugoira]
      @frame_data = data[:ugoira_frame_data]
      @content_type = data[:ugoira_content_type]
    end
  end

  def empty?
    @frame_data.nil?
  end
end
