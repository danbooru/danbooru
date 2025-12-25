# frozen_string_literal: true

class MetricsPolicy < ApplicationPolicy
  alias_method :instance?, :index?
  alias_method :statistics?, :index?
end
