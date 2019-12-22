module PaginationExtension
  class PaginationError < Exception; end

  attr_accessor :current_page, :records_per_page, :paginator_count, :paginator_mode

  def paginate(page, limit: nil, count: nil, search_count: nil)
    @records_per_page = limit || Danbooru.config.posts_per_page
    @records_per_page = @records_per_page.to_i.clamp(1, 1000)

    if count.present?
      @paginator_count = count
    elsif !search_count.nil? && search_count.blank?
      @paginator_count = 1_000_000
    end

    if page =~ /\Ab(\d+)\z/i
      @paginator_mode = :sequential_before
      paginate_sequential_before($1, records_per_page)
    elsif page =~ /\Aa(\d+)\z/i
      @paginator_mode = :sequential_after
      paginate_sequential_after($1, records_per_page)
    else
      @paginator_mode = :numbered
      @current_page = [page.to_i, 1].max
      raise PaginationError if current_page > Danbooru.config.max_numbered_pages

      paginate_numbered(current_page, records_per_page)
    end
  end

  def paginate_sequential_before(before_id, limit)
    where("#{table_name}.id < ?", before_id).reorder("#{table_name}.id desc").limit(limit + 1)
  end

  def paginate_sequential_after(after_id, limit)
    where("#{table_name}.id > ?", after_id).reorder("#{table_name}.id asc").limit(limit + 1)
  end

  def paginate_numbered(page, limit)
    offset((page - 1) * limit).limit(limit)
  end

  def is_first_page?
    if paginator_mode == :numbered
      current_page == 1
    elsif paginator_mode == :sequential_before
      false
    elsif paginator_mode == :sequential_after
      size <= records_per_page
    end
  end

  def is_last_page?
    if paginator_mode == :numbered
      current_page >= total_pages
    elsif paginator_mode == :sequential_before
      size <= records_per_page
    elsif paginator_mode == :sequential_after
      false
    end
  end

  # XXX Hack: in sequential pagination we fetch one more record than we
  # need so that we can tell when we're on the first or last page. Here
  # we override a rails internal method to discard that extra record. See
  # #2044, #3642.
  def records
    if paginator_mode == :sequential_before
      super.first(records_per_page)
    elsif paginator_mode == :sequential_after
      super.first(records_per_page).reverse
    elsif paginator_mode == :numbered
      super
    end
  end

  def total_pages
    (total_count.to_f / records_per_page).ceil
  end

  # taken from kaminari (https://github.com/amatsuda/kaminari)
  def total_count
    @paginator_count ||= except(:offset, :limit, :order).reorder(nil).count
  rescue ActiveRecord::StatementInvalid => e
    if e.to_s =~ /statement timeout/
      1_000_000
    else
      raise
    end
  end
end
