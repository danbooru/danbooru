# frozen_string_literal: true

class ReactionPolicy < ApplicationPolicy
  def create?
    false
  end

  def destroy?
    false
  end

  def permitted_attributes
    [:model_id, :model_type, :reaction_id]
  end

  def searchable_attributes
    %i[id created_at updated_at creator model reaction_id]
  end
end
