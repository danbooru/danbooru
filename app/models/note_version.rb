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
    @previous ||= begin
      NoteVersion.where("note_id = ? and updated_at < ?", note_id, updated_at).order("updated_at desc").limit(1).to_a
    end
    @previous.first
  end

  def self.status_fields
    {
      body: "Body",
      was_moved: "Moved",
      was_resized: "Resized",
      was_deleted: "Deleted",
      was_undeleted: "Undeleted",
    }
  end

  def was_moved
    x != previous.x || y != previous.y
  end

  def was_resized
    width != previous.width || height != previous.height
  end

  def was_deleted
    !is_active && previous.is_active
  end

  def was_undeleted
    is_active && !previous.is_active
  end

  def self.available_includes
    [:updater, :note, :post]
  end
end
