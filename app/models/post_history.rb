class PostHistory < ActiveRecord::Base
  class Error < Exception ; end

  before_validation :initialize_revisions, :on => :create
  belongs_to :post
  
  def self.build_revision_for_post(post)
    hash = {
      :source => post.source,
      :rating => post.rating,
      :tag_string => post.tag_string,
      :parent_id => post.parent_id,
      :user_id => CurrentUser.id,
      :ip_addr => CurrentUser.ip_addr,
      :updated_at => revision_time
    }
  end
  
  def self.revision_time
    Time.now
  end
  
  def initialize_revisions
    write_attribute(:revisions, "[]")
  end
  
  def revisions
    if read_attribute(:revisions).blank?
      []
    else
      JSON.parse(read_attribute(:revisions))
    end
  end
  
  def <<(post)
    revision = self.class.build_revision_for_post(post)
    write_attribute(:revisions, (revisions << revision).to_json)
    save
  end
end
