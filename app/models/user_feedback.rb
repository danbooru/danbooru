class UserFeedback < ActiveRecord::Base
  self.table_name = "user_feedback"
  belongs_to :user
  belongs_to :creator, :class_name => "User"
  before_validation :initialize_creator, :on => :create
  attr_accessible :body, :user_id, :category, :user_name
  validates_presence_of :user, :creator, :body, :category
  validate :creator_is_privileged

  module SearchMethods
    def positive
      where("category = ?", "positive")
    end
    
    def neutral
      where("category = ?", "neutral")
    end
    
    def negative
      where("category = ?", "negative")
    end
    
    def for_user(user_id)
      where("user_id = ?", user_id)
    end
    
    def search(params)
      q = scoped
      return q if params.blank?
      
      if params[:user_id]
        q = q.for_user(params[:user_id].to_i)
      end
      
      q
    end
  end
    
  extend SearchMethods
  
  def initialize_creator
    self.creator_id = CurrentUser.id
  end
  
  def user_name
    if user
      user.name
    else
      nil
    end
  end
  
  def user_name=(name)
    self.user_id = User.name_to_id(name)
  end
  
  def creator_is_privileged
    if !creator.is_privileged?
      errors[:creator] << "must be privileged"
    end
  end
end
