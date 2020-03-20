class PostAppealPolicy < ApplicationPolicy
  def permitted_attributes
    [:post_id, :reason]
  end
end
