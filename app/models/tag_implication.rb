class TagImplication < ActiveRecord::Base
  before_save :clear_cache
  before_save :update_descendant_names
  after_save :update_descendant_names_for_parent
  after_save :update_cache
  after_save :update_posts
  after_destroy :clear_cache
  after_destroy :clear_remote_cache
  belongs_to :creator, :class_name => "User"
  before_validation :initialize_creator, :on => :create
  validates_presence_of :creator_id
  validates_uniqueness_of :antecedent_name, :scope => :consequent_name
  validate :absence_of_circular_relation
  
  module CacheMethods
    def clear_cache
      Cache.delete("ti:#{Cache.sanitize(antecedent_name)}")
      @descendants = nil
    end

    def clear_remote_cache
      Danbooru.config.other_server_hosts.each do |server|
        Net::HTTP.delete(URI.parse("http://#{server}/tag_implications/#{id}/cache"))
      end
    end

    def update_cache
      descendant_names_array
      true
    end
  end

  module DescendantMethods
    extend ActiveSupport::Concern
    
    module ClassMethods
      def with_descendants(names)
        names + Cache.get_multi(names.flatten, "ti") do |name|
          ([name] + where(["antecedent_name = ?", name]).all.map {|x| x.descendant_names_array}).flatten
        end.values.flatten.uniq
      end
    end
    
    def descendants
      @descendants ||= begin
        [].tap do |all|
          children = [consequent_name]

          until children.empty?
            all.concat(children)
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
      p = parent
      
      while p
        p.update_descendant_names!
        p = p.parent
      end
    end

    def clear_descendants_cache
      @descendants = nil
    end
  end
  
  module ParentMethods
    def parent
      @parent ||= self.class.where(["consequent_name = ?", antecedent_name]).first
    end
    
    def clear_parent_cache
      @parent = nil
    end
  end
  
  include CacheMethods
  include DescendantMethods
  include ParentMethods
  
  def initialize_creator
    self.creator_id = CurrentUser.user.id
  end
  
  def absence_of_circular_relation
    # We don't want a -> b && b -> a chains
    if self.class.exists?(["antecedent_name = ? and consequent_name = ?", consequent_name, antecedent_name])
      self.errors[:base] << "Tag implication can not create a circular relation with another tag implication"
      false
    end
  end
  
  def update_posts
    Post.tag_match(antecedent_name).find_each do |post|
      escaped_antecedent_name = Regexp.escape(antecedent_name)
      fixed_tags = post.tag_string.sub(/(?:\A| )#{escaped_antecedent_name}(?:\Z| )/, " #{antecedent_name} #{descendant_names} ").strip
      post.update_attributes(
        :tag_string => fixed_tags
      )
    end
  end
  
  def reload(options = {})
    super
    clear_parent_cache
    clear_descendants_cache
  end
end
