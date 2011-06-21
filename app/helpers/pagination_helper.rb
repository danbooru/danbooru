module PaginationHelper
  def smart_paginator(records, &block)
    if records.is_sequential_paginator? || params[:page].to_i > 200
      sequential_paginator(records)
    else
      numbered_paginator(records, &block)
    end
  end
  
  def sequential_paginator(records)
    html = "<menu>"
    
    unless records.is_first_page?
      html << '<li>' + link_to("&laquo; Previous", params.merge(:page => "b#{records.first_id}")) + '</li>'
    end
    
    unless records.is_last_page?
      html << '<li>' + link_to("Next &raquo;", params.merge(:page => "a#{records.last_id}")) + '</li>'
    end
    
    html << "</menu>"
    html.html_safe
  end
  
  def numbered_paginator(records, &block)
    html = "<menu>"
    window = 3
    if records.total_pages <= (window * 2) + 5
      1.upto(records.total_pages) do |page|
        html << numbered_paginator_item(page, records.current_page, &block)
      end
    elsif records.current_page <= window + 2
      1.upto(records.current_page + window) do |page|
        html << numbered_paginator_item(page, records.current_page, &block)
      end
      html << numbered_paginator_item("...", records.current_page, &block)
      html << numbered_paginator_final_item(records.total_pages, records.current_page, &block)
    elsif records.current_page >= records.total_pages - (window + 1)
      html << numbered_paginator_item(1, records.current_page, &block)
      html << numbered_paginator_item("...", records.current_page, &block)
      (records.current_page - window).upto(records.total_pages) do |page|
        html << numbered_paginator_item(page, records.current_page, &block)
      end
    else
      html << numbered_paginator_item(1, records.current_page, &block)
      html << numbered_paginator_item("...", records.current_page, &block)
      (records.current_page - window).upto(records.current_page + window) do |page|
        html << numbered_paginator_item(page, records.current_page, &block)
      end
      html << numbered_paginator_item("...", records.current_page, &block)
      html << numbered_paginator_final_item(records.total_pages, records.current_page, &block)
    end
    html << "</menu>"
    html.html_safe
  end
  
  def numbered_paginator_final_item(total_pages, current_page, &block)
    if total_pages <= 200
      numbered_paginator_item(total_pages, current_page, &block)
    else
      ""
    end
  end
  
  def numbered_paginator_item(page, current_page, &block)
    html = "<li>"
    if page == "..."
      html << "..."
    elsif page == current_page
      html << page.to_s
    else
      html << capture(page, &block)
    end
    html << "</li>"
    html.html_safe
  end
end
