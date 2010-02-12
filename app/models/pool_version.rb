class PoolVersion < ActiveRecord::Base
  class Error < Exception ; end
  
  validates_presence_of :updater_id, :updater_ip_addr
  belongs_to :pool
end
