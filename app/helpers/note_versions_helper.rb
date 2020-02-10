module NoteVersionsHelper
  def note_version_position_diff(note_version)
    previous = note_version.previous

    html = "#{note_version.x},#{note_version.y}"
    if previous.nil?
      html
    else
      "#{previous.x},#{previous.y} -> " + html
    end
  end

  def note_version_size_diff(note_version)
    previous = note_version.previous

    html = "#{note_version.width}x#{note_version.height}"
    if previous.nil?
      html
    else
      "#{previous.width}x#{previous.height}  -> " + html
    end
  end
end
