module ArtistVersionsHelper
  def artist_versions_listing_type
    (params.dig(:search, :artist_id).present? && CurrentUser.is_member?) ? :revert : :standard
  end

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
end
