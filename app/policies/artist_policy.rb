# frozen_string_literal: true

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
    !user.is_anonymous?
  end

  def rate_limit_for_write(**_options)
    if user.is_builder?
      { rate: 1.0 / 1.minute, burst: 50 }
    else
      { rate: 1.0 / 1.minute, burst: 10 }
    end
  end

  def permitted_attributes
    [:name, :other_names, :other_names_string, :group_name, :url_string, :is_deleted]
  end

  def permitted_attributes_for_new
    permitted_attributes + [:source]
  end

  alias_method :banned?, :index?
  alias_method :show_or_new?, :show?
end
