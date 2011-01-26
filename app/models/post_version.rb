class PostVersion < ActiveRecord::Base
  belongs_to :post
  belongs_to :updater, :class_name => "User"
  before_validation :initialize_updater
  
  def self.create_from_post(post)
    if post.created_at == post.updated_at
      create_from_created_post(post)
    else
      create_from_updated_post(post)
    end
  end
  
  def initialize_updater
    self.updater_id = CurrentUser.id
    self.updater_ip_addr = CurrentUser.ip_addr
  end
  
  def add_tag_array
    @add_tag_array ||= add_tags.scan(/\S+/)
  end
  
  def del_tag_array
    @del_tag_array ||= del_tags.scan(/\S+/)
  end
  
  def presenter
    PostVersionPresenter.new(self)
  end
  
  def reload
    @add_tag_array = nil
    @del_tag_array = nil
    super
  end
end
