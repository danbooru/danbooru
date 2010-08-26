class PostVote < ActiveRecord::Base
  class Error < Exception ; end
  
  attr_accessor :is_positive
  belongs_to :post
end
