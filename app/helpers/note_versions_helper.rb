module NoteVersionsHelper
  def note_version_position_diff(note_version)
    previous = note_version.previous

    html = "#{note_version.x},#{note_version.y}"
    if previous.nil? || (note_version.x == previous.x && note_version.y == previous.y)
      html
    else
      "#{previous.x},#{previous.y} -> " + html
    end
  end

  def note_version_size_diff(note_version)
    previous = note_version.previous

    html = "#{note_version.width}x#{note_version.height}"
    if previous.nil? || (note_version.width == previous.width && note_version.height == previous.height)
      html
    else
      "#{previous.width}x#{previous.height}  -> " + html
    end
  end
end
