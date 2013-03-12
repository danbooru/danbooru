class TagAlias < ActiveRecord::Base
  after_save :clear_all_cache
  after_save :update_cache
  after_save :ensure_category_consistency
  after_destroy :clear_all_cache
  before_validation :initialize_creator, :on => :create
  validates_presence_of :creator_id, :antecedent_name, :consequent_name
  validates_uniqueness_of :antecedent_name
  validate :absence_of_transitive_relation
  belongs_to :creator, :class_name => "User"
  belongs_to :forum_topic
  
  module SearchMethods
    def name_matches(name)
      where("(antecedent_name like ? escape E'\\\\' or consequent_name like ? escape E'\\\\')", name.downcase.to_escaped_for_sql_like, name.downcase.to_escaped_for_sql_like)
    end
    
    def search(params)
      q = scoped
      return q if params.blank?
      
      if params[:name_matches].present?
        q = q.name_matches(params[:name_matches])
      end
      
      if params[:antecedent_name].present?
        q = q.where("antecedent_name = ?", params[:antecedent_name])
      end

      if params[:id].present?
        q = q.where("id = ?", params[:id].to_i)
      end
      
      q
    end
  end
  
  extend SearchMethods
  
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
    clear_all_cache
    update_posts
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
  
  def ensure_category_consistency
    if antecedent_tag && consequent_tag && antecedent_tag.category != consequent_tag.category
      consequent_tag.update_attribute(:category, antecedent_tag.category)
    end
    
    true
  end
  
  def clear_all_cache
    Danbooru.config.all_server_hosts.each do |host|
      delay(:queue => host).clear_cache
    end
  end

  def clear_cache
    Cache.delete("ta:#{Cache.sanitize(antecedent_name)}")
    Cache.delete("ta:#{Cache.sanitize(consequent_name)}")
  end
  
  def update_cache
    Cache.put("ta:#{Cache.sanitize(antecedent_name)}", consequent_name)
    Cache.delete("ta:#{Cache.sanitize(consequent_name)}")
  end
  
  def update_posts
    Post.raw_tag_match(antecedent_name).find_each do |post|
      escaped_antecedent_name = Regexp.escape(antecedent_name)
      fixed_tags = post.tag_string.sub(/(?:\A| )#{escaped_antecedent_name}(?:\Z| )/, " #{consequent_name} ").strip
      CurrentUser.scoped(creator, creator_ip_addr) do
        post.update_attributes(
          :tag_string => fixed_tags
        )
      end
    end

    antecedent_tag.fix_post_count if antecedent_tag
    consequent_tag.fix_post_count if consequent_tag
  end
end
