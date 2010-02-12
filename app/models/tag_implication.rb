class TagImplication < ActiveRecord::Base
  attr_accessor :updater_id, :updater_ip_addr
  before_save :clear_cache
  before_save :update_descendant_names
  after_save :update_descendant_names_for_parent
  after_destroy :clear_cache
  after_save :update_posts
  belongs_to :creator, :class_name => "User"
  belongs_to :updater, :class_name => "User"
  validates_presence_of :updater_id, :updater_ip_addr, :creator_id
  validates_uniqueness_of :antecedent_name, :scope => :consequent_name
  validate :absence_of_circular_relation
  
  def self.with_descendants(names)
    ([names] + where(["antecedent_name IN (?)", Array(names)]).all.map {|x| x.descendant_names_array}).flatten
  end
  
  def absence_of_circular_relation
    # We don't want a -> b && b -> a chains
    if self.class.exists?(["antecedent_name = ? and consequent_name = ?", consequent_name, antecedent_name])
      self.errors[:base] << "Tag implication can not create a circular relation with another tag implication"
      false
    end
  end
  
  def parent
    @parent ||= self.class.where(["consequent_name = ?", antecedent_name]).first
  end
  
  def descendants
    all = []
    children = [consequent_name]
    
    until children.empty?
      all += children
      children = self.class.where(["antecedent_name IN (?)", children]).all.map(&:consequent_name)
    end
    
    all
  end
  
  def descendant_names_array
    Cache.get("ti:#{Cache.sanitize(antecedent_name)}") do
      descendant_names.split(/ /)
    end
  end
  
  def update_descendant_names
    self.descendant_names = descendants.join(" ")
    self.class.logger.debug "#{antecedent_name}> updating descendants to #{descendant_names}"
  end
  
  def update_descendant_names!(updater_id, updater_ip_addr)
    update_descendant_names
    self.updater_id = updater_id
    self.updater_ip_addr = updater_ip_addr
    save!
  end
  
  def update_descendant_names_for_parent
    if parent
      self.class.logger.debug "#{antecedent_name}> updating parent #{parent.antecedent_name}"
      parent.update_descendant_names!(updater_id, updater_ip_addr)
    end
  end

  def clear_cache
    Cache.delete("ti:#{Cache.sanitize(antecedent_name)}")
  end
  
  def update_posts
    Post.find_by_tags(antecedent_name).find_each do |post|
      escaped_antecedent_name = Regexp.escape(antecedent_name)
      fixed_tags = post.tag_string.sub(/\A#{escaped_antecedent_name} | #{escaped_antecedent_name} | #{escaped_antecedent_name}\Z/, " #{antecedent_name} #{descendant_names} ").strip
      post.update_attributes(
        :tag_string => fixed_tags,
        :updater_id => updater_id,
        :updater_ip_addr => updater_ip_addr
      )
    end
  end
  
  def reload(options = {})
    super
    clear_parent_cache
  end
  
  def clear_parent_cache
    @parent = nil
  end
end
