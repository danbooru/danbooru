class ArtistCommentaryVersion < ApplicationRecord
  belongs_to :post
  belongs_to_updater

  def self.search(params)
    q = super
    q = q.search_attributes(params, :post, :updater, :original_title, :original_description, :translated_title, :translated_description)
    q.apply_default_order(params)
  end

  module ApiMethods
    def html_data_attributes
      [:post_id, :updater_id]
    end
  end

  include ApiMethods
end
