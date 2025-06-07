# frozen_string_literal: true

class LegacyControllerPolicy < ApplicationPolicy
  alias_method :posts?, :index?
  alias_method :tags?, :index?
end
