# frozen_string_literal: true

class BackupCodePolicy < ApplicationPolicy
  def index?
    record == user
  end

  def create?
    record == user
  end

  def rate_limit_for_create(**_options)
    { rate: 1.0 / 1.minute, burst: 10 }
  end
end
