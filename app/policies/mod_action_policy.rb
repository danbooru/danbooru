# frozen_string_literal: true

class ModActionPolicy < ApplicationPolicy
  def api_attributes
    super + [:category_id]
  end
end
