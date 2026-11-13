# frozen_string_literal: true

class NoteVersionPolicy < ApplicationPolicy
  def searchable_attributes
    %i[id created_at updated_at is_active x y width height body version updater note post]
  end
end
