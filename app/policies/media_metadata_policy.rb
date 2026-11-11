# frozen_string_literal: true

class MediaMetadataPolicy < ApplicationPolicy
  def index?
    true
  end

  def searchable_attributes
    %i[id created_at updated_at media_asset metadata]
  end
end
