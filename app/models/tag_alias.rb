class TagAlias < ActiveRecord::Base
  after_save :clear_all_cache
  after_save :update_cache
  after_destroy :clear_all_cache
  before_validation :initialize_creator, :on => :create
  validates_presence_of :creator_id
  validates_uniqueness_of :antecedent_name
  validate :absence_of_transitive_relation
  belongs_to :creator, :class_name => "User"
  scope :name_matches, lambda {|name| where("(antecedent_name = ? or consequent_name = ?)", name.downcase, name.downcase)}
  search_method :name_matches
  
  def self.to_aliased(names)
    alias_hash = Cache.get_multi(names.flatten, "ta") do |name|
      ta = TagAlias.find_by_antecedent_name(name)
      if ta && ta.is_active?
        ta.consequent_name
      else
        name
      end
    end
    
    alias_hash.values.flatten.uniq
  end
  
  def process!
    update_column(:status, "processing")
    update_posts
    clear_all_cache
    update_column(:status, "active")
  rescue Exception => e
    update_column(:status, "error: #{e}")
  end
  
  def is_pending?
    status == "pending"
  end
  
  def is_active?
    status == "active"
  end
  
  def initialize_creator
    self.creator_id = CurrentUser.user.id
    self.creator_ip_addr = CurrentUser.ip_addr
  end
  
  def antecedent_tag
    Tag.find_by_name(antecedent_name)
  end
  
  def consequent_tag
    Tag.find_by_name(consequent_name)
  end
  
  def absence_of_transitive_relation
    # We don't want a -> b && b -> c chains
    if self.class.exists?(["antecedent_name = ?", consequent_name]) || self.class.exists?(["consequent_name = ?", antecedent_name])
      self.errors[:base] << "Tag alias can not create a transitive relation with another tag alias"
      false
    end
  end
  
  def clear_all_cache
    Danbooru.config.all_server_hosts.each do |host|
      delay.clear_cache(host)
    end
  end

  def clear_cache(host = Socket.gethostname)
    if host == Socket.gethostname
      Cache.delete("ta:#{Cache.sanitize(antecedent_name)}")
    end
  end
  
  def update_cache
    Cache.put("ta:#{Cache.sanitize(antecedent_name)}", consequent_name)
  end
  
  def update_posts
    Post.tag_match(antecedent_name).find_each do |post|
      escaped_antecedent_name = Regexp.escape(antecedent_name)
      fixed_tags = post.tag_string.sub(/(?:\A| )#{escaped_antecedent_name}(?:\Z| )/, " #{consequent_name} ").strip
      
      CurrentUser.scoped(creator, creator_ip_addr) do
        post.update_attributes(
          :tag_string => fixed_tags
        )
      end
    end
  end
end
