# frozen_string_literal: true

class ArtistVersionPolicy < ApplicationPolicy
  def can_view_banned?
    policy(Artist).can_view_banned?
  end

  def searchable_attributes
    %i[id created_at updated_at is_deleted is_banned name group_name urls other_names updater artist]
  end
end
