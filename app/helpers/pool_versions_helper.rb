module PoolVersionsHelper
  def pool_versions_listing_type
    params.dig(:search, :pool_id).present? ? :revert : :standard
  end

end
