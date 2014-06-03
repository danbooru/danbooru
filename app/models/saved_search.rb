class SavedSearch < ActiveRecord::Base
  belongs_to :user
  validates :tag_query, :presence => true
  validate :validate_count
  attr_accessible :tag_query, :category
  before_create :update_user_on_create
  after_destroy :update_user_on_destroy
  validates_uniqueness_of :tag_query, :scope => :user_id

  def self.tagged(tags)
    where(:tag_query => tags).first
  end

  def validate_count
    if user.saved_searches.count + 1 > user.max_saved_searches
      self.errors[:user] << "can only have up to #{user.max_saved_searches} " + "saved search".pluralize(user.max_saved_searches)
    end
  end

  def update_user_on_create
    if !user.has_saved_searches?
      user.update_attribute(:has_saved_searches, true)
    end
  end

  def update_user_on_destroy
    if user.saved_searches.count == 0
      user.update_attribute(:has_saved_searches, false)
    end
  end
end
