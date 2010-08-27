class TagImplication < ActiveRecord::Base
  attr_accessor :creator_ip_addr
  before_save :clear_cache
  before_save :update_descendant_names
  after_save :update_descendant_names_for_parent
  after_destroy :clear_cache
  after_save :update_posts
  belongs_to :creator, :class_name => "User"
  validates_presence_of :creator_id, :creator_ip_addr
  validates_uniqueness_of :antecedent_name, :scope => :consequent_name
  validate :absence_of_circular_relation
  
  def self.with_descendants(names)
    Cache.get_multi(names.flatten, "ti") do |name|
      ([name] + where(["antecedent_name = ?", name]).all.map {|x| x.descendant_names_array}).flatten
    end.values.flatten.uniq
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
    @descendants ||= begin
      [].tap do |all|
        children = [consequent_name]
    
        until children.empty?
          all += children
          children = self.class.where(["antecedent_name IN (?)", children]).all.map(&:consequent_name)
        end
      end
    end
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
    save!
  end
  
  def update_descendant_names_for_parent
    if parent
      parent.update_descendant_names!
    end
  end

  def clear_cache
    Cache.delete("ti:#{Cache.sanitize(antecedent_name)}")
  end
  
  def update_posts
    Post.find_by_tags(antecedent_name).find_each do |post|
      escaped_antecedent_name = Regexp.escape(antecedent_name)
      fixed_tags = post.tag_string.sub(/(?:\A| )#{escaped_antecedent_name}(?:\Z| )/, " #{antecedent_name} #{descendant_names} ").strip
      CurrentUser.scoped(creator, creator_ip_addr) do
        post.update_attributes(
          :tag_string => fixed_tags
        )
      end
    end
  end
  
  def reload(options = {})
    super
    clear_parent_cache
    clear_descendants_cache
  end
  
  def clear_descendants_cache
    @descendants = nil
  end
  
  def clear_parent_cache
    @parent = nil
  end
end
