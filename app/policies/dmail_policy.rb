class DmailPolicy < ApplicationPolicy
  def create?
    unbanned?
  end

  def index?
    user.is_member?
  end

  def mark_all_as_read?
    user.is_member?
  end

  def update?
    user.is_member? && record.owner_id == user.id
  end

  def show?
    user.is_member? && (record.owner_id == user.id || record.valid_key?(request.params[:key]))
  end

  def reportable?
    unbanned? && record.owner_id == user.id && record.is_recipient? && !record.is_automated? && !record.from.is_moderator?
  end

  def permitted_attributes_for_create
    [:title, :body, :to_name, :to_id]
  end

  def permitted_attributes_for_update
    [:is_read, :is_deleted]
  end

  def api_attributes
    super + [:key]
  end
end
