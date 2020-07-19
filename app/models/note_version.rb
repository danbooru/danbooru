class NoteVersion < ApplicationRecord
  belongs_to :post
  belongs_to :note
  belongs_to_updater :counter_cache => "note_update_count"

  def self.search(params)
    q = super

    q = q.search_attributes(params, :is_active, :x, :y, :width, :height, :body, :version)
    q = q.text_attribute_matches(:body, params[:body_matches])

    q.apply_default_order(params)
  end

  def previous
    @previous ||= begin
      NoteVersion.where("note_id = ? and version < ?", note_id, version).order("updated_at desc").limit(1).to_a
    end
    @previous.first
  end

  def subsequent
    @subsequent ||= begin
      NoteVersion.where("note_id = ? and version > ?", note_id, version).order("updated_at asc").limit(1).to_a
    end
    @subsequent.first
  end

  def current
    @current ||= begin
      NoteVersion.where("note_id = ?", note_id).order("updated_at desc").limit(1).to_a
    end
    @current.first
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

  def was_moved(type)
    other = self.send(type)
    x != other.x || y != other.y
  end

  def was_resized(type)
    other = self.send(type)
    width != other.width || height != other.height
  end

  def was_deleted(type)
    other = self.send(type)
    if type == "previous"
      !is_active && other.is_active
    else
      is_active && !other.is_active
    end
  end

  def was_undeleted(type)
    other = self.send(type)
    if type == "previous"
      is_active && !other.is_active
    else
      !is_active && other.is_active
    end
  end

  def self.searchable_includes
    [:updater, :note, :post]
  end

  def self.available_includes
    [:updater, :note, :post]
  end
end
