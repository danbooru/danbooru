class TagAlias < ActiveRecord::Base
  after_save :update_posts
  
  def self.to_aliased(names)
    alias_hash = Cache.get_multi(names, "ta") do |name|
      ta = TagAlias.find_by_antecedent_name(name)
      if ta
        ta.consequent_name
      else
        name
      end
    end
  end
  
  def update_posts
  end
end
