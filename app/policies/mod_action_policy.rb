# frozen_string_literal: true

class ModActionPolicy < ApplicationPolicy
  def show?
    user.is_moderator? || !record.category.to_sym.in?(ModAction::MOD_ONLY_CATEGORIES)
  end

  def visible(relation)
    if user.is_moderator?
      relation
    else
      relation.where.not(category: ModAction::MOD_ONLY_CATEGORIES)
    end
  end

  def searchable_attributes
    %i[id created_at updated_at category description creator subject]
  end

  def api_attributes
    super + [:category_id]
  end
end
