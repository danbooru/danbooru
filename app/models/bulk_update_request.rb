class BulkUpdateRequest < ActiveRecord::Base
  attr_accessor :title, :reason

  belongs_to :user
  belongs_to :forum_topic

  validates_presence_of :user
  validates_inclusion_of :status, :in => %w(pending approved rejected)
  attr_accessible :user_id, :forum_topic_id, :script, :title, :reason
  attr_accessible :status, :as => [:admin]
  before_validation :initialize_attributes, :on => :create
  after_create :create_forum_topic

  def approve!
    AliasAndImplicationImporter.new(script, forum_topic_id, "1").process!
    update_attribute(:status, "approved")
  end

  def create_forum_topic
    forum_topic = ForumTopic.create(:title => "[bulk] #{title}", :category_id => 1, :original_post_attributes => {:body => reason_with_link})
    update_attribute(:forum_topic_id, forum_topic.id)
  end

  def reason_with_link
    "[code]\n#{script}\n[/code]\n\nh4. Reason\n\n#{reason}\n\n\"Link to request\":/bulk_update_requests/#{id}\n"
  end

  def reject!
    update_attribute(:status, "rejected")
  end

  def initialize_attributes
    self.user_id = CurrentUser.user.id unless self.user_id
    self.status = "pending"
  end
end
