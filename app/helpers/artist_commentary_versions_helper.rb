module ArtistCommentaryVersionsHelper
  def artist_commentary_versions_listing_type
    params.dig(:search, :post_id).present? ? :revert : :standard
  end

end
