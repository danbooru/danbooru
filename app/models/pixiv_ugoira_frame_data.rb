class PixivUgoiraFrameData < ApplicationRecord
  serialize :data
  before_validation :normalize_data, on: :create

  def normalize_data
    return if data.nil?
    
    if data[0]["delay_msec"]
      self.data = data.map.with_index do |datum, i|
        filename = "%06d.jpg" % [i]
        {"delay" => datum["delay_msec"], "file" => filename}
      end
    end
  end
end
