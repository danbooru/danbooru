class Unapproval < ActiveRecord::Base
  class Error < Exception ; end
  
  belongs_to :unapprover, :class_name => "User"
  belongs_to :post
  validates_presence_of :reason, :unapprover_id, :unapprover_ip_addr
  validate :validate_post_is_active
  before_validation :initialize_unapprover, :on => :create
  before_save :flag_post
  
  def validate_post_is_active
    if post.is_pending? || post.is_flagged? || post.is_removed?
      errors[:post] << "is inactive"
      false
    else
      true
    end
  end
  
  def flag_post
    post.update_attribute(:is_flagged, true)
  end
  
  def initialize_unapprover
    self.unapprover_id = CurrentUser.id
    self.unapprover_ip_addr = CurrentUser.ip_addr
  end
end
