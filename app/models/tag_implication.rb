class TagImplication < ActiveRecord::Base
  after_save :update_descendant_names
  
  def self.with_descendants(names)
    names.map do |name|
      ti = TagImplication.find_by_antecedent_name(name)
      if ti
        [name, ti.descendant_name_array]
      else
        name
      end
    end.flatten
  end
  
  def descendants
    all = []
    children = [consequent_name]
    
    until children.empty?
      all += children
      children = where(["antecedent_name IN (?)", children]).all.map(&:consequent_name)
    end
  end
  
  def descendant_name_array
    descendant_names.split(/ /)
  end
  
  def update_desecendant_names
    self.descendant_names = descendants.join(" ")
  end
end
