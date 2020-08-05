class LinkedAccountPolicy < ApplicationPolicy
  def create?
    user.is_member?
  end

  def update?
    record.user_id == user.id
  end

  def index?
    request.params[:user_id].blank? || request.params[:user_id].to_i == user.id
  end

  def permitted_attributes
    [:is_public]
  end
end
