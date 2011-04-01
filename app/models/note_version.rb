class NoteVersion < ActiveRecord::Base
  before_validation :initialize_updater
  belongs_to :updater, :class_name => "User"
  
  def initialize_updater
    self.updater_id = CurrentUser.id
    self.updater_ip_addr = CurrentUser.ip_addr
  end

  def updater_name
    User.id_to_name(updater_id)
  end
end
