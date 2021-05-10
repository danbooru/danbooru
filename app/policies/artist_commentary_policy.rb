class ArtistCommentaryPolicy < ApplicationPolicy
  def create_or_update?
    unbanned?
  end

  def revert?
    unbanned?
  end

  def permitted_attributes
    %i[
      original_description original_title
      translated_description translated_title
      remove_commentary_tag remove_commentary_request_tag
      remove_commentary_check_tag remove_partial_commentary_tag
      add_commentary_tag add_commentary_request_tag
      add_commentary_check_tag add_partial_commentary_tag
    ]
  end
end
