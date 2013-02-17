class ModAction < ActiveRecord::Base
  belongs_to :creator, :class_name => "User"
  before_validation :initialize_creator, :on => :create
  
  def self.search(params = {})
    q = scoped()
    
    if params[:creator_id]
      q = q.where("creator_id = ?", params[:creator_id].to_i)
    end
    
    q
  end
  
  def initialize_creator
    self.creator_id = CurrentUser.id
  end
end
