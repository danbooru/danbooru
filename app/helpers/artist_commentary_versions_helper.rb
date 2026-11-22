# frozen_string_literal: true

module ArtistCommentaryVersionsHelper
  def commentary_version_field_diff(commentary_version, type, field)
    other = (type == "current") ? commentary_version.current : commentary_version.previous
    if type == "previous"
      diff_body_html(commentary_version, other, field)
    else
      diff_body_html(other, commentary_version, field)
    end
  end
end
