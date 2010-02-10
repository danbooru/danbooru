class Unapproval < ActiveRecord::Base
  class Error < Exception ; end
  
  belongs_to :unapprover, :class_name => "User"
  validates_presence_of :reason, :unapprover_id, :unapprover_ip_addr
end
