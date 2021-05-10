class ModActionPolicy < ApplicationPolicy
  def api_attributes
    super + [:category_id]
  end
end
