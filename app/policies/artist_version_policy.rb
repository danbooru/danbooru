# frozen_string_literal: true

class ArtistVersionPolicy < ApplicationPolicy
  def can_view_banned?
    policy(Artist).can_view_banned?
  end
end
