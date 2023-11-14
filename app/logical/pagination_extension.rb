# frozen_string_literal: true

# A mixin that adds a `#paginate` method to an ActiveRecord relation.
#
# There are two pagination techniques. The first is page-based (numbered):
#
#   https://danbooru.donmai.us/posts?page=1
#   https://danbooru.donmai.us/posts?page=2
#   https://danbooru.donmai.us/posts?page=3
#
# The second is id-based (sequential):
#
#   https://danbooru.donmai.us/posts?page=a1000&limit=100
#   https://danbooru.donmai.us/posts?page=a1100&limit=100
#   https://danbooru.donmai.us/posts?page=a1200&limit=100
#
#   https://danbooru.donmai.us/posts?page=b1000&limit=100
#   https://danbooru.donmai.us/posts?page=b900&limit=100
#   https://danbooru.donmai.us/posts?page=b800&limit=100
#
# where a1000 means "after id 1000" and b1000 means "before id 1000".
#
module PaginationExtension
  class PaginationError < StandardError; end

  attr_accessor :current_page, :records_per_page, :paginator_count, :paginator_mode, :paginator_page_limit

  # Paginate an ActiveRecord relation. Returns a relation for the given page and number of posts per page.
  #
  # @param page [String] the page number, or an "aNNN" or "bNNN" string
  # @param limit [Integer] the number of posts per page
  # @param max_limit [Integer] the maximum number of posts per page the user can view
  # @param page_limit [Integer] the highest page the user can view
  # @param count [Integer] the precalculated number of search results, or nil to calculate it
  # @param search_count [Object] if truthy, don't calculate the number of results; assume a large number of results
  def paginate(page, limit: nil, max_limit: 1000, page_limit: CurrentUser.user.page_limit, count: nil, search_count: nil)
    @records_per_page = limit || Danbooru.config.posts_per_page
    @records_per_page = @records_per_page.to_i.clamp(1, max_limit)
    @paginator_page_limit = page_limit

    if count.present?
      @paginator_count = count
    elsif !search_count.nil? && search_count.blank?
      @paginator_count = Float::INFINITY
    end

    if page.to_s =~ /\Ab(\d+)\z/i
      @paginator_mode = :sequential_before
      paginate_sequential_before($1, records_per_page)
    elsif page.to_s =~ /\Aa(\d+)\z/i
      @paginator_mode = :sequential_after
      paginate_sequential_after($1, records_per_page)
    elsif page.to_i > page_limit
      raise PaginationError, "You cannot go beyond page #{page_limit}."
    elsif page.to_i == page_limit
      @paginator_mode = :sequential_after
      paginate_numbered(page.to_i, records_per_page)
    else
      @paginator_mode = :numbered
      @current_page = [page.to_i, 1].max

      paginate_numbered(current_page, records_per_page)
    end
  end

  def paginate_sequential_before(before_id, limit)
    where("#{table_name}.id < ?", before_id).reorder("#{table_name}.id DESC").limit(limit + 1)
  end

  def paginate_sequential_after(after_id, limit)
    where("#{table_name}.id > ?", after_id).reorder("#{table_name}.id ASC").limit(limit + 1)
  end

  def paginate_numbered(page, limit)
    offset((page - 1) * limit).limit(limit)
  end

  def is_first_page?
    case paginator_mode
    when :numbered
      current_page == 1
    when :sequential_before
      false
    when :sequential_after
      load
      @records.size <= records_per_page
    end
  end

  def is_last_page?
    case paginator_mode
    when :numbered
      current_page >= total_pages
    when :sequential_before
      load
      @records.size <= records_per_page
    when :sequential_after
      false
    end
  end

  def prev_page
    if is_first_page?
      nil
    elsif paginator_mode == :numbered
      current_page - 1
    elsif records.present?
      "a#{records.first.id}"
    else
      nil
    end
  rescue ActiveRecord::QueryCanceled
    nil
  end

  def next_page
    if is_last_page?
      nil
    elsif paginator_mode == :numbered
      current_page + 1
    elsif records.present?
      "b#{records.last.id}"
    else
      nil
    end
  rescue ActiveRecord::QueryCanceled
    nil
  end

  # XXX Hack: in sequential pagination we fetch one more record than we
  # need so that we can tell when we're on the first or last page. Here
  # we override a rails internal method to discard that extra record. See
  # #2044, #3642.
  def records
    case paginator_mode
    when :sequential_before
      super.first(records_per_page)
    when :sequential_after
      super.first(records_per_page).reverse
    when :numbered
      super
    end
  end

  # Return the number of pages of results, or infinity if it takes too long to count.
  def total_pages
    return Float::INFINITY if total_count.infinite?
    (total_count.to_f / records_per_page).ceil
  end

  # Return the number of results, or infinity if it takes too long to count.
  def total_count
    @paginator_count ||= unscoped.from(except(:offset, :limit, :order).reorder(nil)).count
  rescue ActiveRecord::StatementInvalid => e
    raise unless e.to_s =~ /statement timeout/
    @paginator_count ||= Float::INFINITY
  end
end
