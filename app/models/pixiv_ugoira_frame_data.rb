class PixivUgoiraFrameData < ApplicationRecord
  belongs_to :post

  serialize :data
  before_validation :normalize_data, on: :create

  def self.searchable_includes
    [:post]
  end

  def self.available_includes
    [:post]
  end

  def self.search(params)
    q = super
    q = q.search_attributes(params, :data, :content_type)
    q.apply_default_order(params)
  end

  def normalize_data
    return if data.nil?

    if data[0]["delay_msec"]
      self.data = data.map.with_index do |datum, i|
        filename = format("%06d.jpg", i)
        {"delay" => datum["delay_msec"], "file" => filename}
      end
    end
  end
end
