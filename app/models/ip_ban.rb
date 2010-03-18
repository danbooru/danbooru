class IpBan < ActiveRecord::Base
  belongs_to :creator, :class_name => "User"
  validates_presence_of :reason
  validates_uniqueness_of :ip_addr
  
  def self.is_banned?(ip_addr)
    exists?(["ip_addr = ?", ip_addr])
  end
end
