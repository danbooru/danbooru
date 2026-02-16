# frozen_string_literal: true

class ArtistURLPolicy < ApplicationPolicy
  def permitted_attributes
    [:is_active]
  end

  def permitted_attributes_for_create
    [:url, :artist_id, :is_active]
  end
end
