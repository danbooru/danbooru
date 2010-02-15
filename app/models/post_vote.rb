class PostVote < ActiveRecord::Base
  class Error < Exception ; end
  
  belongs_to :post
end
