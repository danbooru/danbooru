class PostNavbarComponent < ApplicationComponent
  extend Memoist

  attr_reader :post, :current_user, :search, :pool_id, :favgroup_id

  def initialize(post:, current_user:, search: nil, pool_id: nil, favgroup_id: nil)
    @post = post
    @current_user = current_user
    @search = search.presence || "status:any"
    @pool_id = pool_id&.to_i
    @favgroup_id = favgroup_id&.to_i
  end

  def render?
    has_search_navbar? || pools.any? || favgroups.any?
  end

  def pools
    post.pools.undeleted.sort_by do |pool|
      [pool.id == pool_id ? 0 : 1, pool.is_series? ? 0 : 1, pool.name]
    end
  end

  def favgroups
    current_user.favorite_groups.for_post(post.id).sort_by do |favgroup|
      [favgroup.id == favgroup_id ? 0 : 1, favgroup.name]
    end
  end

  def has_search_navbar?
    !has_order_metatag? && pool_id.blank? && favgroup_id.blank?
  end

  def has_order_metatag?
    PostQueryBuilder.new(search).has_metatag?(:order, :ordfav, :ordpool)
  end

  memoize :pools, :favgroups
end
