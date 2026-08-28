# frozen_string_literal: true

class UpgradeCodePolicy < ApplicationPolicy
  def index?
    user.is_superadmin?
  end

  def redeem?
    true
  end

  def upgrade?
    unbanned?
  end
end
