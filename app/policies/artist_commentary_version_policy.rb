# frozen_string_literal: true

class ArtistCommentaryVersionPolicy < ApplicationPolicy
  def searchable_attributes
    %i[id created_at updated_at original_title original_description translated_title translated_description post updater]
  end
end
