class NoteVersion < ActiveRecord::Base
  before_validation :initialize_updater
  belongs_to :updater, :class_name => "User"
  scope :for_user, lambda {|user_id| where("updater_id = ?", user_id)}
  default_scope limit(1)
  
  def initialize_updater
    self.updater_id = CurrentUser.id
    self.updater_ip_addr = CurrentUser.ip_addr
  end

  def updater_name
    User.id_to_name(updater_id)
  end
end
