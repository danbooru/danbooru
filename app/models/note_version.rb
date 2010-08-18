class NoteVersion < ActiveRecord::Base
  def updater_name
    User.id_to_name(updater_id)
  end
end
