module PaginationHelper
  def sequential_paginator(records)
    html = '<div class="paginator"><menu>'

    if records.any?
      if params[:page] =~ /[ab]/
        html << '<li>' + link_to("< Previous", params.merge(:page => "a#{records[0].id}"), :rel => "prev") + '</li>'
      end

      html << '<li>' + link_to("Next >", params.merge(:page => "b#{records[-1].id}"), :rel => "next") + '</li>'
    end

    html << "</menu></div>"
    html.html_safe
  end

  def use_sequential_paginator?(records)
    params[:page] =~ /[ab]/ || records.current_page >= Danbooru.config.max_numbered_pages
  end

  def numbered_paginator(records, switch_to_sequential = true)
    if use_sequential_paginator?(records) && switch_to_sequential
      return sequential_paginator(records)
    end

    html = '<div class="paginator"><menu>'
    window = 3

    if records.current_page >= 2
      html << "<li>" + link_to("<<", params.merge(:page => records.current_page - 1), :rel => "prev") + "</li>"
    end

    if records.total_pages <= (window * 2) + 5
      1.upto(records.total_pages) do |page|
        html << numbered_paginator_item(page, records.current_page)
      end

    elsif records.current_page <= window + 2
      1.upto(records.current_page + window) do |page|
        html << numbered_paginator_item(page, records.current_page)
      end
      html << numbered_paginator_item("...", records.current_page)
      html << numbered_paginator_final_item(records.total_pages, records.current_page)
    elsif records.current_page >= records.total_pages - (window + 1)
      html << numbered_paginator_item(1, records.current_page)
      html << numbered_paginator_item("...", records.current_page)
      (records.current_page - window).upto(records.total_pages) do |page|
        html << numbered_paginator_item(page, records.current_page)
      end
    else
      html << numbered_paginator_item(1, records.current_page)
      html << numbered_paginator_item("...", records.current_page)
      if records.size > 0
        right_window = records.current_page + window
      else
        right_window = records.current_page
      end
      (records.current_page - window).upto(right_window) do |page|
        html << numbered_paginator_item(page, records.current_page)
      end
      if records.size > 0
        html << numbered_paginator_item("...", records.current_page)
        html << numbered_paginator_final_item(records.total_pages, records.current_page)
      end
    end

    if records.current_page < records.total_pages && records.size > 0
      html << "<li>" + link_to(">>", params.merge(:page => records.current_page + 1), :rel => "next") + "</li>"
    end

    html << "</menu></div>"
    html.html_safe
  end

  def numbered_paginator_final_item(total_pages, current_page)
    if total_pages <= Danbooru.config.max_numbered_pages
      numbered_paginator_item(total_pages, current_page)
    else
      ""
    end
  end

  def numbered_paginator_item(page, current_page)
    return "" if page.to_i > Danbooru.config.max_numbered_pages

    html = "<li>"
    if page == "..."
      html << "..."
    elsif page == current_page
      html << '<span>' + page.to_s + '</span>'
    else
      html << link_to(page, params.merge(:page => page))
    end
    html << "</li>"
    html.html_safe
  end
end
