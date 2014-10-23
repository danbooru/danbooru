class PixivUgoiraService
  attr_reader :width, :height, :frame_data, :content_type

  def process(post)
    save_frame_data(post)
  end

  def save_frame_data(post)
    PixivUgoiraFrameData.create(:data => @frame_data, :content_type => @content_type, :post_id => post.id)
  end

  def generate_resizes(source_path, output_path, preview_path)
    # Run this a bit in the future to give the upload process time to move the file
    PixivUgoiraConverter.delay(:queue => Socket.gethostname, :run_at => 2.seconds.from_now).convert(source_path, output_path, preview_path, @frame_data)

    # since the resizes will be delayed, just touch the output file so the
    # file distribution wont break
    FileUtils.touch([output_path, preview_path])
  end

  def load(data)
    @frame_data = data[:ugoira_frame_data]
    @width = data[:ugoira_width]
    @height = data[:ugoira_height]
    @content_type = data[:ugoira_content_type]
  end
end
