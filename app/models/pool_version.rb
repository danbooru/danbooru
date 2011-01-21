class PoolVersion < ActiveRecord::Base
  class Error < Exception ; end
  
  validates_presence_of :updater_id, :updater_ip_addr
  belongs_to :pool
  before_validation :initialize_updater
  
  def initialize_updater
    self.updater_id = CurrentUser.id
    self.updater_ip_addr = CurrentUser.ip_addr
  end
end
