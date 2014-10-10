class PixivUgoiraFrameData < ActiveRecord::Base
  attr_accessible :post_id, :data
  serialize :data
end
