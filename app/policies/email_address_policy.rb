# frozen_string_literal: true

class EmailAddressPolicy < ApplicationPolicy
  def index?
    user.is_moderator?
  end

  def show?
    record.user_id == user.id || (user.is_moderator? && record.user.level < user.level)
  end

  def update?
    # XXX here record is a user, not the email address.
    record.id == user.id && !user.is_banned?
  end

  def verify?
    record.user_id == user.id
  end

  def send_confirmation?
    # XXX record is a user, not the email address.
    record.id == user.id
  end
end
