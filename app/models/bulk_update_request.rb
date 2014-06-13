class BulkUpdateRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :forum_topic

  validates_presence_of :user
  validates_inclusion_of :status, :in => %w(pending approved rejected)
  attr_accessible :user_id, :forum_topic_id, :script
  attr_accessible :status, :as => [:admin]
  before_validation :initialize_attributes, :on => :create

  def approve!
    AliasAndImplicationImporter.new(script, forum_topic_id, "1").process!
    update_attribute(:status, "approved")
  end

  def reject!
    update_attribute(:status, "rejected")
  end

  def initialize_attributes
    self.user_id = CurrentUser.user.id unless self.user_id
    self.status = "pending"
  end
end
