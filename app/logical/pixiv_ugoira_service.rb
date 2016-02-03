class PixivUgoiraService
  attr_reader :width, :height, :frame_data, :content_type

  def self.regen(post)
    service = new()
    service.load(
      :is_ugoira => true,
      :ugoira_frame_data => post.pixiv_ugoira_frame_data.data
    )
    service.generate_resizes(post.file_path, post.large_file_path, post.preview_file_path, false)
  end

  def save_frame_data(post)
    PixivUgoiraFrameData.create(:data => @frame_data, :content_type => @content_type, :post_id => post.id)
  end

  def generate_resizes(source_path, output_path, preview_path, delay = true)
    # Run this a bit in the future to give the upload process time to move the file
    if delay
      PixivUgoiraConverter.delay(:queue => Socket.gethostname, :run_at => 10.seconds.from_now, :priority => -1).convert(source_path, output_path, preview_path, @frame_data)
    else
      PixivUgoiraConverter.convert(source_path, output_path, preview_path, @frame_data)
    end

    # since the resizes will be delayed, just touch the output file so the
    # file distribution wont break
    FileUtils.touch([output_path, preview_path])
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
