module ArtistVersionsHelper
  def artist_version_other_names_diff(artist_version)
    diff = artist_version.other_names_diff(artist_version.previous)
    html = []
    diff[:added_names].each do |name|
      html << '<ins>' + name + '</ins>'
    end
    diff[:removed_names].each do |name|
      html << '<del>' + name + '</del>'
    end
    diff[:unchanged_names].each do |name|
      html << '<span>' + name + '</span>'
    end
    return html.join(" ").html_safe
  end

  def artist_version_urls_diff(artist_version)
    diff = artist_version.urls_diff(artist_version.previous)
    html = []
    diff[:added_urls].each do |url|
      html << '<li><ins>' + url + '</ins></li>'
    end
    diff[:removed_urls].each do |url|
      html << '<li><del>' + url + '</del></li>'
    end
    diff[:unchanged_urls].each do |url|
      html << '<li><span>' + url + '</span></li>'
    end
    return html.join(" ").html_safe
  end
end
