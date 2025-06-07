# frozen_string_literal: true

class WikiPageVersionPolicy < ApplicationPolicy
  alias_method :diff?, :show?
end
