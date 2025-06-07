# frozen_string_literal: true

class PoolVersionPolicy < ApplicationPolicy
  alias_method :diff?, :index?
end
