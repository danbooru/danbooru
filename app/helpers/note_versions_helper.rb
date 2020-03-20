module NoteVersionsHelper
  def note_version_position_diff(note_version, type)
    other = note_version.send(type)

    html = "#{note_version.x},#{note_version.y}"
    if other.nil? || (note_version.x == other.x && note_version.y == other.y)
      html
    elsif type == "previous"
      "#{other.x},#{other.y} -> " + html
    else
      html + " -> #{other.x},#{other.y}"
    end
  end

  def note_version_size_diff(note_version, type)
    other = note_version.send(type)

    html = "#{note_version.width}x#{note_version.height}"
    if other.nil? || (note_version.width == other.width && note_version.height == other.height)
      html
    elsif type == "previous"
      "#{other.width}x#{other.height} -> " + html
    else
      html + " -> #{other.width}x#{other.height}"
    end
  end

  def note_version_body_diff(note_version, type)
    other = note_version.send(params[:type])
    if type == "previous"
      diff_body_html(note_version, other, :body)
    else
      diff_body_html(other, note_version, :body)
    end
  end
end
