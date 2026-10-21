# frozen_string_literal: true

class IqdbClientPolicy < ApplicationPolicy
  def index?
    !user.is_anonymous?
  end
end
