class NewsUpdate < ApplicationRecord
  belongs_to_creator
  belongs_to_updater
  scope :recent, -> {where("created_at >= ?", 2.weeks.ago).order("created_at desc").limit(5)}

  module ApiMethods
    def html_data_attributes
      [:creator_id, :updater_id]
    end
  end

  include ApiMethods
end
