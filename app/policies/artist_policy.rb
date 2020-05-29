class ArtistPolicy < ApplicationPolicy
  def ban?
    user.is_admin? && !record.is_banned?
  end

  def unban?
    user.is_admin? && record.is_banned?
  end

  def revert?
    unbanned?
  end

  def can_view_banned?
    user.is_member?
  end

  def permitted_attributes
    [:name, :other_names, :other_names_string, :group_name, :url_string, :is_deleted]
  end

  def permitted_attributes_for_new
    permitted_attributes + [:source]
  end
end
