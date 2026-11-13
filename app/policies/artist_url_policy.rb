# frozen_string_literal: true

class ArtistURLPolicy < ApplicationPolicy
  def searchable_attributes
    %i[id created_at updated_at url is_active artist]
  end
end
