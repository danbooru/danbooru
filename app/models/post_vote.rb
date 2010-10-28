class PostVote < ActiveRecord::Base
  class Error < Exception ; end
  
  belongs_to :post
  before_validation :initialize_user, :on => :create
  validates_presence_of :post_id, :user_id, :score
  validates_inclusion_of :score, :in => [1, -1]

  def score=(x)
    if x == "up"
      write_attribute(:score, 1)
    elsif x == "down"
      write_attribute(:score, -1)
    end
  end
  
  def initialize_user
    self.user_id = CurrentUser.user.id
  end
end
