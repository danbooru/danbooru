class ModAction < ApplicationRecord
  belongs_to :creator, :class_name => "User"
  before_validation :initialize_creator, :on => :create
  validates_presence_of :creator_id
  attr_accessible :description, :category

  #####DIVISIONS#####
  #Groups:     0-999
  #Individual: 1000-1999
  #####Actions#####
  #Create:   0
  #Update:   1
  #Delete:   2
  #Undelete: 3
  #Ban:      4
  #Unban:    5
  #Misc:     6-19
  enum category: {
    user_delete: 2,
    user_ban: 4,
    user_name_change: 6,
    user_level: 7,
    user_approval_privilege: 8,
    user_upload_privilege: 9,
    user_feedback_update: 21,
    user_feedback_delete: 22,
    post_delete: 42,
    post_undelete: 43,
    post_ban: 44,
    post_unban: 45,
    post_permanent_delete: 46,
    pool_delete: 62,
    pool_undelete: 63,
    comment_update: 81,
    comment_delete: 82,
    forum_post_update: 101,
    forum_post_delete: 102,
    tag_alias_create: 120,
    tag_alias_update: 121,
    tag_implication_create: 140,
    tag_implication_update: 141,
    ip_ban_create: 160,
    ip_ban_delete: 162,
    mass_update: 1000,
    bulk_revert: 1001,
    other: 2000
  }

  def self.search(params = {})
    q = where("true")
    return q if params.blank?

    if params[:creator_id].present?
      q = q.where("creator_id = ?", params[:creator_id].to_i)
    end

    q
  end

  def category_id
    self.class.categories[category]
  end

  def method_attributes
    super + [:category_id]
  end

  def self.log(desc, cat = :other)
    create(:description => desc,:category => categories[cat])
  end

  def initialize_creator
    self.creator_id = CurrentUser.id
  end
end
