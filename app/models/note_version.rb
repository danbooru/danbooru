class NoteVersion < ApplicationRecord
  belongs_to_updater :counter_cache => "note_update_count"
  scope :for_user, lambda {|user_id| where("updater_id = ?", user_id)}

  def self.search(params)
    q = super

    if params[:updater_id]
      q = q.where(updater_id: params[:updater_id].split(",").map(&:to_i))
    end

    if params[:post_id]
      q = q.where(post_id: params[:post_id].split(",").map(&:to_i))
    end

    if params[:note_id]
      q = q.where(note_id: params[:note_id].split(",").map(&:to_i))
    end

    q.apply_default_order(params)
  end

  def previous
    NoteVersion.where("note_id = ? and updated_at < ?", note_id, updated_at).order("updated_at desc").first
  end
end
