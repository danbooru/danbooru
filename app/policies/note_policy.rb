class NotePolicy < ApplicationPolicy
  def revert?
    update?
  end

  def permitted_attributes_for_create
    [:x, :y, :width, :height, :body, :post_id, :html_id]
  end

  def permitted_attributes_for_update
    [:x, :y, :width, :height, :body]
  end
end
