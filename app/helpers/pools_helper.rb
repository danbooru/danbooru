module PoolsHelper
  def recent_pool_list
    pool_ids = session[:recent_pool_ids].to_s.split(/,/)
    pool_ids.map {|x| content_tag("option", x, :value => x)}.join("\n").html_safe
  end
end
