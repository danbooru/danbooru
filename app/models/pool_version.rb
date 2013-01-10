class PoolVersion < ActiveRecord::Base
  class Error < Exception ; end
  
  validates_presence_of :updater_id, :updater_ip_addr
  belongs_to :pool
  belongs_to :updater, :class_name => "User"
  before_validation :initialize_updater

  module SearchMethods
    def for_user(user_id)
      where("updater_id = ?", user_id)
    end
    
    def search(params)
      q = scoped
      return q if params.blank?
      
      if params[:updater_id]
        q = q.for_user(params[:updater_id].to_i)
      end
      
      q
    end
  end
  
  extend SearchMethods
  
  def initialize_updater
    self.updater_id = CurrentUser.id
    self.updater_ip_addr = CurrentUser.ip_addr
  end
  
  def post_id_array
    @post_id_array ||= post_ids.scan(/\d+/).map(&:to_i)
  end
end
