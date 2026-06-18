# frozen_string_literal: true

class ModActionPolicy < ApplicationPolicy
  def show?
    user.is_moderator? || !record.category.to_sym.in?(ModAction::MOD_ONLY_CATEGORIES)
  end

  def api_attributes
    super + [:category_id]
  end
end
