module ArtistVersionsHelper
  def artist_version_other_names_diff(artist_version)
    new_names = artist_version.other_names
    old_names = artist_version.previous.try(:other_names)
    latest_names = artist_version.artist.other_names

    diff_list_html(new_names, old_names, latest_names)
  end

  def artist_version_urls_diff(artist_version)
    new_urls = artist_version.urls
    old_urls = artist_version.previous.try(:urls)
    latest_urls = artist_version.artist.urls.map(&:to_s)

    diff_list_html(new_urls, old_urls, latest_urls)
  end

  def artist_version_name_diff(artist_version)
    previous = artist_version.previous
    if previous.present? && (artist_version.name != previous.name)
      name_diff = diff_name_html(artist_version.name, previous.name)
      %(<br><br><b>Rename:</b><br>&ensp;#{name_diff}</p>).html_safe
    else
      ""
    end
  end

  def artist_version_group_name_diff(artist_version)
    previous = artist_version.previous
    if artist_version.group_name.present? || (previous.present? && previous.group_name.present?)
      group_name_diff = diff_name_html(artist_version.group_name, previous.group_name)
      %(<b>Group:</b><br>&ensp;#{group_name_diff}<br><br>).html_safe
    else
      ""
    end
  end
end
