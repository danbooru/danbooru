# frozen_string_literal: true

class MetricsPolicy < ApplicationPolicy
  alias_method :instance?, :index?
end
