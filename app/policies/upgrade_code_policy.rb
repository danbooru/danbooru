# frozen_string_literal: true

class UpgradeCodePolicy < ApplicationPolicy
  def index?
    user.is_owner?
  end

  def redeem?
    true
  end

  def upgrade?
    unbanned?
  end
end
