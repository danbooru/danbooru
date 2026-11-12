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

  def visible(relation)
    if user.is_owner?
      relation
    elsif user.is_anonymous?
      relation.none
    else
      relation.where(redeemer: user).or(relation.where(creator: user))
    end
  end

  def searchable_attributes
    %i[id created_at updated_at code status creator redeemer user_upgrade]
  end
end
