module PoolsHelper
  def recent_updated_pools(&block)
    pool_ids = session[:recent_pool_ids].to_s.scan(/\d+/)
    Pool.where(["id IN (?)", pool_ids]).each(&block) if pool_ids.any?
  end
end
