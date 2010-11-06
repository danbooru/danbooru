class PostHistory < ActiveRecord::Base
  class Error < Exception ; end
  
  class Revision
    attr_accessor :prev, :hash, :diff, :tag_array
    
    def initialize(hash)
      @hash = hash
      @diff = {}
      @tag_array = Tag.scan_tags(@hash["tag_string"])
    end
    
    def calculate_diff
      if prev.nil?
        diff[:add] = tag_array
        diff[:del] = []
        diff[:rating] = rating
        diff[:source] = source
        diff[:parent_id] = parent_id
      else
        diff[:del] = prev.tag_array - tag_array
        diff[:add] = tag_array - prev.tag_array
        
        if prev.rating != rating
          diff[:rating] = rating
        end
        
        if prev.source != source
          diff[:source] = source
        end
        
        if prev.parent_id != parent_id
          diff[:parent_id]= parent_id
        end
      end
    end
    
    def rating
      hash["rating"]
    end
    
    def source
      hash["source"]
    end
    
    def parent_id
      hash["parent_id"]
    end
    
    def updated_at
      hash["updated_at"]
    end
    
    def user_id
      hash["user_id"]
    end

    def presenter
      @presenter ||= PostHistoryRevisionPresenter.new(self)
    end
  end

  before_validation :initialize_revisions, :on => :create
  belongs_to :post
  
  def self.build_revision_for_post(post)
    hash = {
      :source => post.source,
      :rating => post.rating,
      :tag_string => post.tag_string,
      :parent_id => post.parent_id,
      :user_id => CurrentUser.id,
      :ip_addr => CurrentUser.ip_addr,
      :updated_at => revision_time
    }
  end
  
  def self.revision_time
    Time.now
  end
  
  def initialize_revisions
    write_attribute(:revisions, "[]")
  end
  
  def revisions
    if read_attribute(:revisions).blank?
      []
    else
      JSON.parse(read_attribute(:revisions))
    end
  end
  
  def <<(post)
    revision = self.class.build_revision_for_post(post)
    write_attribute(:revisions, (revisions << revision).to_json)
    save
  end
  
  def each_revision(&block)
    array = revisions.map {|x| Revision.new(x)}
    link_revisions(array)
    array.each {|x| x.calculate_diff}
    array.each(&block)
  end
  
  private
    def link_revisions(array)
      1.upto(array.size - 1) do |i|
        array[i].prev = array[i - 1]
      end
    end
  
end
