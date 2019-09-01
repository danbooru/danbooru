class NoteVersion < ApplicationRecord
  belongs_to :post
  belongs_to :note
  belongs_to_updater :counter_cache => "note_update_count"

  def self.search(params)
    q = super

    q = q.search_attributes(params, :updater, :is_active, :post, :note_id, :x, :y, :width, :height, :body, :version)
    q = q.text_attribute_matches(:body, params[:body_matches])

    q.apply_default_order(params)
  end

  def previous
    NoteVersion.where("note_id = ? and updated_at < ?", note_id, updated_at).order("updated_at desc").first
  end
end
