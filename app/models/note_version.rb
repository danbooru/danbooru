class NoteVersion < ApplicationRecord
  before_validation :initialize_updater
  belongs_to :updater, :class_name => "User", :counter_cache => "note_update_count"
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

  def initialize_updater
    self.updater_id = CurrentUser.id
    self.updater_ip_addr = CurrentUser.ip_addr
  end

  def previous
    NoteVersion.where("note_id = ? and updated_at < ?", note_id, updated_at).order("updated_at desc").first
  end

  def updater_name
    User.id_to_name(updater_id)
  end
end
