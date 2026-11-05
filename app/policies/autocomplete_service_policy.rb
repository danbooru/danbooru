# frozen_string_literal: true

class AutocompleteServicePolicy < ApplicationPolicy
  def rate_limit_for_index(**_options)
    { rate: 5.0 / 1.second, burst: 100 }
  end
end
