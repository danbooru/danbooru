class NoteVersion < ActiveRecord::Base
  def updater_name
    User.find_name(updater_id)
  end
end
