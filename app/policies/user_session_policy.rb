# frozen_string_literal: true

class UserSessionPolicy < ApplicationPolicy
  def index?
    user.is_admin?
  end
end
