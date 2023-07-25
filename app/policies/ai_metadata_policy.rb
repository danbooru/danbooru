# frozen_string_literal: true

class AIMetadataPolicy < ApplicationPolicy
  def create_or_update?
    unbanned?
  end

  def undo?
    create_or_update?
  end

  def revert?
    create_or_update?
  end

  def permitted_attributes
    %i[
      prompt negative_prompt sampler seed steps cfg_scale model_hash
    ]
  end
end
