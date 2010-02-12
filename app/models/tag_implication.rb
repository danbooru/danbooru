class TagImplication < ActiveRecord::Base
  attr_accessor :updater_id, :updater_ip_addr
  before_save :update_descendant_names
  after_save :update_descendant_names_for_parent
  after_save :clear_cache
  after_destroy :clear_cache
  after_save :update_posts
  belongs_to :creator, :class_name => "User"
  belongs_to :updater, :class_name => "User"
  validates_presence_of :updater_id, :updater_ip_addr, :creator_id
  
  def self.with_descendants(names)
    names.map do |name|
      ti = find_by_antecedent_name(name)
      if ti
        [name, ti.descendant_names_array]
      else
        name
      end
    end.flatten
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
  end
  
  def update_descendant_names!
    update_descendant_names
    save
  end
  
  def update_descendant_names_for_parent
    parent.update_descendant_names! if parent
  end

  def clear_cache
    Cache.delete("ti:#{Cache.sanitize(antecedent_name)}")
  end
  
  def update_posts
    Post.find_by_tags(antecedent_name).find_each do |post|
      escaped_antecedent_name = Regexp.escape(antecedent_name)
      fixed_tags = post.tag_string.sub(/\A#{escaped_antecedent_name} | #{escaped_antecedent_name} | #{escaped_antecedent_name}\Z/, " #{descendant_names} ").strip
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
