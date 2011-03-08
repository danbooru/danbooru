module PoolsHelper
  def recent_updated_pools
    pool_ids = session[:recent_pool_ids].to_s.scan(/\d+/)
    if pool_ids.any?
      Pool.where(["id IN (?)", pool_ids])
    else
      []
    end
  end
end
