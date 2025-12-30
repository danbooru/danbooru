# frozen_string_literal: true

class ArtistURLPolicy < ApplicationPolicy
  def permitted_attributes
    [:is_active, :parent_id]
  end

  def permitted_attributes_for_create
    [:url, :artist_id, :is_active, :parent_id]
  end
end
