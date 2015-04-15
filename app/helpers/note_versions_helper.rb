module NoteVersionsHelper
  def note_version_body_diff_info(note_version)
    previous = note_version.previous
    if previous.nil?
      return ""
    end

    html = ""
    if note_version.body == previous.body
      html += '<span class="inactive">(body not changed)</span>'
    end

    html.html_safe
  end

  def note_version_position_diff(note_version)
    previous = note_version.previous

    html = "#{note_version.width}x#{note_version.height}"
    html += " #{note_version.x},#{note_version.y}"
    if previous.nil?
      html
    elsif note_version.x == previous.x && note_version.y == previous.y && note_version.width == previous.width && note_version.height == previous.height
      html
    else
      html = '<span style="text-decoration: underline;">' + html + '</span>'
      html.html_safe
    end
  end
end
