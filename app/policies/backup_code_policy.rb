# frozen_string_literal: true

class BackupCodePolicy < ApplicationPolicy
  def index?
    record == user
  end

  def create?
    record == user
  end

  def recover?
    policy(record).can_recover_account?
  end

  def rate_limit_for_create(**_options)
    { rate: 1.0 / 1.minute, burst: 10 }
  end

  def rate_limit_for_recover(**_options)
    { rate: 1.0 / 10.minutes, burst: 3 }
  end

  alias_method :confirm_recover?, :recover?
end
