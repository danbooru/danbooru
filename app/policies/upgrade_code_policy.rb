# frozen_string_literal: true

class UpgradeCodePolicy < ApplicationPolicy
  def index?
    false
  end

  def redeem?
    true
  end

  def upgrade?
    unbanned?
  end

  def visible(relation)
    if user.is_anonymous?
      relation.none
    else
      relation.where(redeemer: user).or(relation.where(creator: user))
    end
  end

  def searchable_attributes
    %i[id created_at updated_at code status creator redeemer user_upgrade]
  end

  def rate_limit_for_upgrade(**_options)
    { rate: 1.0 / 10.minutes, burst: 3 }
  end
end
