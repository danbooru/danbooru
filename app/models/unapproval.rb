class Unapproval < ActiveRecord::Base
  class Error < Exception ; end
  
  belongs_to :unapprover, :class_name => "User"
  validates_presence_of :reason, :unapprover_id, :unapprover_ip_addr
  before_validation :initialize_unapprover, :on => :create
  
  def initialize_unapprover
    self.unapprover_id = CurrentUser.id
    self.unapprover_ip_addr = CurrentUser.ip_addr
  end
end
