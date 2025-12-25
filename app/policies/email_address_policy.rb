# frozen_string_literal: true

class EmailAddressPolicy < ApplicationPolicy
  def index?
    user.is_moderator?
  end

  def show?
    if record.user_id == user.id
      true
    elsif user.is_moderator?
      record.user.level < user.level
    else
      false
    end
  end

  def update?
    if record.user_id == user.id
      !user.is_banned?
    else
      policy(record.user).can_recover_account?
    end
  end

  def destroy?
    record.user_id == user.id
  end

  def verify?
    record.user_id == user.id
  end

  def send_confirmation?
    # XXX record is a user, not the email address.
    record.id == user.id
  end

  def rate_limit_for_update(**_options)
    if record.invalid?
      { action: "email_addresses:write:invalid", rate: 1.0 / 1.second, burst: 5 }
    else
      { rate: 1.0 / 10.minutes, burst: 3 }
    end
  end

  def permitted_attributes_for_update
    [:address]
  end
end
