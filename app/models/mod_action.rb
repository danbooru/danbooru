class ModAction < ActiveRecord::Base
  belongs_to :creator, :class_name => "User"
  before_validation :initialize_creator, :on => :create
  validates_presence_of :creator_id
  attr_accessible :description

  def self.search(params = {})
    q = where("true")
    return q if params.blank?

    if params[:creator_id].present?
      q = q.where("creator_id = ?", params[:creator_id].to_i)
    end

    q
  end

  def self.log(desc)
    create(:description => desc)
  end

  def initialize_creator
    self.creator_id = CurrentUser.id
  end
end
