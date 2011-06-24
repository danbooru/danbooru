module PaginationHelper
  def sequential_paginator(records)
    html = "<menu>"
    
    if records.any? 
      if params[:page] =~ /[ab]/
        html << '<li>' + link_to("< Previous", params.merge(:page => "a#{records[0].id}")) + '</li>'
      end
    
      html << '<li>' + link_to("Next >", params.merge(:page => "b#{records[-1].id}")) + '</li>'
    end
    
    html << "</menu>"
    html.html_safe
  end
  
  def use_sequential_paginator?(records)
    params[:page] =~ /[ab]/ || records.current_page > Danbooru.config.max_numbered_pages
  end
  
  def numbered_paginator(records, &block)
    if use_sequential_paginator?(records)
      return sequential_paginator(records)
    end
    
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
    if total_pages <= Danbooru.config.max_numbered_pages
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
      html << '<span>' + page.to_s + '</span>'
    else
      html << capture(page, &block)
    end
    html << "</li>"
    html.html_safe
  end
end
