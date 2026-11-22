# frozen_string_literal: true

module ArtistCommentaryVersionsHelper
  def commentary_version_field_diff(commentary_version, type, field)
    other = commentary_version.send(params[:type]) # set_version_comparison limits params[:type] to previous or current.
    if type == "previous"
      diff_body_html(commentary_version, other, field)
    else
      diff_body_html(other, commentary_version, field)
    end
  end
end
