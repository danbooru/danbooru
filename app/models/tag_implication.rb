class TagImplication < ActiveRecord::Base
  def after_save :update_descendant_names
    
  def descendants
    all = []
    children = [consequent_name]
    
    until children.empty?
      all += children
      children = where(["antecedent_name IN (?)", children]).all.map(&:consequent_name)
    end
  end
  
  def update_desecendant_names
    self.descendant_names = descendants.join(" ")
  end
end
