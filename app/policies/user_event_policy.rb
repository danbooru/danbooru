# frozen_string_literal: true

class UserEventPolicy < ApplicationPolicy
  def index?
    user.is_moderator?
  end
end
