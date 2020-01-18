class NewsUpdate < ApplicationRecord
  belongs_to :creator, class_name: "User"
  belongs_to_updater
  scope :recent, -> {where("created_at >= ?", 2.weeks.ago).order("created_at desc").limit(5)}
end
