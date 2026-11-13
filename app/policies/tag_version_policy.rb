# frozen_string_literal: true

class TagVersionPolicy < ApplicationPolicy
  def searchable_attributes
    %i[id created_at updated_at version name category is_deprecated tag updater previous_version]
  end
end
