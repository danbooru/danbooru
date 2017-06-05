module ArtistVersionsHelper
  def artist_version_other_names_diff(artist_version)
    diff = artist_version.other_names_diff(artist_version.previous)
    html = '<span class="diff-list">'

    diff[:added_names].each do |name|
      prefix = diff[:obsolete_added_names].include?(name) ? '<ins class="obsolete">' : '<ins>'
      html << prefix + h(name) + '</ins>'
    end
    diff[:removed_names].each do |name|
      prefix = diff[:obsolete_removed_names].include?(name) ? '<del class="obsolete">' : '<del>'
      html << prefix + h(name) + '</del>'
    end
    diff[:unchanged_names].each do |name|
      html << '<span>' + h(name) + '</span>'
      html << " "
    end

    html << "</span>"
    return html.html_safe
  end

  def artist_version_urls_diff(artist_version)
    diff = artist_version.urls_diff(artist_version.previous)
    html = '<ul class="diff-list">'

    diff[:added_urls].each do |url|
      prefix = diff[:obsolete_added_urls].include?(url) ? '<ins class="obsolete">' : '<ins>'
      html << '<li>' + prefix + h(url) + '</ins></li>'
    end
    diff[:removed_urls].each do |url|
      prefix = diff[:obsolete_removed_urls].include?(url) ? '<del class="obsolete">' : '<del>'
      html << '<li>' + prefix + h(url) + '</del></li>'
    end
    diff[:unchanged_urls].each do |url|
      html << '<li><span>' + h(url) + '</span></li>'
    end

    html << "</ul>"
    html.html_safe
  end
end
