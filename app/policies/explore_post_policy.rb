# frozen_string_literal: true

class ExplorePostPolicy < ApplicationPolicy
  alias_method :popular?, :index?
  alias_method :viewed?, :index?
  alias_method :searches?, :index?
  alias_method :missed_searches?, :index?
end
