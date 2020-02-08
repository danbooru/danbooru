class ArtistCommentaryVersion < ApplicationRecord
  belongs_to :post
  belongs_to_updater

  def self.search(params)
    q = super
    q = q.search_attributes(params, :post, :updater, :original_title, :original_description, :translated_title, :translated_description)
    q.apply_default_order(params)
  end

  def previous
    @previous ||= begin
      ArtistCommentaryVersion.where("post_id = ? and updated_at < ?", post_id, updated_at).order("updated_at desc").limit(1).to_a
    end
    @previous.first
  end
end
