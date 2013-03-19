class AdvertisementHit < ActiveRecord::Base
  belongs_to :advertisement

  scope :between, lambda {|start_date, end_date| where("created_at BETWEEN ? AND ?", start_date, end_date)}
end
