# frozen_string_literal: true

class BackupCodePolicy < ApplicationPolicy
  def index?
    record == user
  end

  def create?
    record == user
  end
end
