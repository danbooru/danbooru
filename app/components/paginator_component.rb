# frozen_string_literal: true

class PaginatorComponent < ApplicationComponent
  attr_reader :records, :window, :params

  delegate :current_page, :prev_page, :next_page, :total_pages, :paginator_mode, :paginator_page_limit, to: :records
  delegate :ellipsis_icon, :chevron_left_icon, :chevron_right_icon, to: :helpers

  def initialize(records:, params:, window: 4)
    super
    @records = records
    @window = window
    @params = params
  end

  def pages
    last_page = total_pages.clamp(1..)
    left = (current_page - window).clamp(2..)
    right = (current_page + window).clamp(..last_page - 1)

    [
      1,
      ("..." unless left == 2),
      (left..right).to_a,
      ("..." unless right == last_page - 1),
      (last_page unless last_page == 1 || last_page.infinite?),
    ].flatten.compact
  end

  def link_to_page(anchor, page = anchor, **options)
    if page.nil?
      tag.span anchor, **options
    else
      hidden = paginator_mode == :numbered && page > paginator_page_limit
      link_to anchor, url_for_page(page), **options, hidden: hidden
    end
  end

  def url_for_page(page)
    url_for(**params.merge(page: page).except(:z).permit!)
  end
end
