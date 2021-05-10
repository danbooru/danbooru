module ArtistVersionsHelper
  def artist_version_other_names_diff(artist_version, type)
    other = artist_version.send(type)
    this_names = artist_version.other_names
    if other.present?
      other_names = other.other_names
    elsif type == "subsequent"
      other_names = this_names
    else
      other_names = []
    end

    if type == "previous"
      diff_list_html(this_names, other_names)
    else
      diff_list_html(other_names, this_names)
    end
  end

  def artist_version_urls_diff(artist_version, type)
    other = artist_version.send(type)
    this_urls = artist_version.urls
    if other.present?
      other_urls = other.urls
    elsif type == "subsequent"
      other_urls = this_urls
    else
      other_urls = []
    end

    if type == "previous"
      diff_list_html(this_urls, other_urls)
    else
      diff_list_html(other_urls, this_urls)
    end
  end

  def artist_version_name_diff(artist_version, type)
    other = artist_version.send(type)
    if other.present? && (artist_version.name != other.name)
      if type == "previous"
        name_diff = diff_name_html(artist_version.name, other.name)
      else
        name_diff = diff_name_html(other.name, artist_version.name)
      end
      %(<br><br><b>Rename:</b><br>&ensp;#{name_diff}</p>).html_safe
    else
      ""
    end
  end

  def artist_version_group_name_diff(artist_version, type)
    other = artist_version.send(type)
    if artist_version.group_name.present? || (other.present? && other.group_name.present?)
      other_group_name = (other.present? ? other.group_name : artist_version.group_name)
      if type == "previous"
        group_name_diff = diff_name_html(artist_version.group_name, other_group_name)
      else
        group_name_diff = diff_name_html(other_group_name, artist_version.group_name)
      end
      %(<b>Group:</b><br>&ensp;#{group_name_diff}<br><br>).html_safe
    else
      ""
    end
  end
end
