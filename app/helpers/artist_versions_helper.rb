module ArtistVersionsHelper
  def artist_version_other_names_diff(artist_version)
    diff = artist_version.other_names_diff(artist_version.previous)
    html = []
    diff[:added_names].each do |name|
      html << '<ins>' + h(name) + '</ins>'
    end
    diff[:removed_names].each do |name|
      html << '<del>' + h(name) + '</del>'
    end
    diff[:unchanged_names].each do |name|
      html << '<span>' + h(name) + '</span>'
    end
    return html.join(" ").html_safe
  end

  def artist_version_urls_diff(artist_version)
    diff = artist_version.urls_diff(artist_version.previous)
    html = []
    diff[:added_urls].each do |url|
      html << '<li><ins>' + h(url) + '</ins></li>'
    end
    diff[:removed_urls].each do |url|
      html << '<li><del>' + h(url) + '</del></li>'
    end
    diff[:unchanged_urls].each do |url|
      html << '<li><span>' + h(url) + '</span></li>'
    end
    return html.join(" ").html_safe
  end
end
