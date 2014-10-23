class PixivUgiraProcessor
  attr_accessor :post, :frame_data, :width, :height

  def load_data(hash)
    @frame_data = hash[:pixiv_ugoira_frame_data]
    @width = hash[:pixiv_ugoira_width]
    @height = hash[:pixiv_ugoira_height]
  end

  def process!(post)
    save_pixiv_ugoira_frame_data(post)
  end

  def save_pixiv_ugoira_frame_data(post)
    PixivUgoiraFrameData.create(:data => frame_data.to_json, :post_id => post.id)
  end
end