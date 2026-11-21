# frozen_string_literal: true

class ModActionPolicy < ApplicationPolicy
  def show?
    category = record.category.to_sym

    if user.is_superadmin?
      true
    elsif user.is_moderator?
      !category.in?(ModAction::SUPERADMIN_ONLY_CATEGORIES)
    else
      !category.in?(ModAction::MOD_ONLY_CATEGORIES + ModAction::SUPERADMIN_ONLY_CATEGORIES)
    end
  end

  def visible(relation)
    if user.is_superadmin?
      relation
    elsif user.is_moderator?
      relation.where.not(category: ModAction::SUPERADMIN_ONLY_CATEGORIES)
    else
      relation.where.not(category: ModAction::MOD_ONLY_CATEGORIES + ModAction::SUPERADMIN_ONLY_CATEGORIES)
    end
  end

  def searchable_attributes
    %i[id created_at updated_at category description creator subject]
  end

  def api_attributes
    super + [:category_id]
  end
end
