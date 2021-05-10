class PoolPolicy < ApplicationPolicy
  def gallery?
    index?
  end

  def update?
    unbanned? && (!record.is_deleted? || user.is_builder?)
  end

  def destroy?
    !record.is_deleted? && user.is_builder?
  end

  def undelete?
    record.is_deleted? && user.is_builder?
  end

  def revert?
    update?
  end

  def permitted_attributes
    [:name, :description, :category, :post_ids, :post_ids_string, post_ids: []]
  end

  def api_attributes
    super + [:post_count]
  end
end
