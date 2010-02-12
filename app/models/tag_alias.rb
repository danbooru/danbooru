class TagAlias < ActiveRecord::Base
  attr_accessor :updater_id, :updater_ip_addr
  after_save :update_posts
  after_save :update_cache
  validates_presence_of :updater_id, :updater_ip_addr
  validates_uniqueness_of :antecedent_name
  belongs_to :updater, :class_name => "User"
  belongs_to :creator, :class_name => "User"
  
  def self.to_aliased(names)
    alias_hash = Cache.get_multi(names.flatten, "ta") do |name|
      ta = TagAlias.find_by_antecedent_name(name)
      if ta
        ta.consequent_name
      else
        name
      end
    end
    
    alias_hash.values.uniq
  end
  
  def update_cache
    Cache.put("ta:#{Cache.sanitize(antecedent_name)}", consequent_name, 24.hours)
  end
  
  def update_posts
    Post.find_by_tags(antecedent_name).find_each do |post|
      escaped_antecedent_name = Regexp.escape(antecedent_name)
      fixed_tags = post.tag_string.sub(/\A#{escaped_antecedent_name} | #{escaped_antecedent_name} | #{escaped_antecedent_name}\Z/, " #{consequent_name} ").strip
      post.update_attributes(
        :tag_string => fixed_tags,
        :updater_id => updater_id,
        :updater_ip_addr => updater_ip_addr
      )
    end
  end
end
