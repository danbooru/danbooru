module PaginationHelper
  def smart_paginator(set, &block)
    if params[:page] && set.page > 1000
      set.extend(PostSets::Sequential)
      sequential_paginator(set)
    else
      set.extend(PostSets::Numbered)
      numbered_paginator(set, &block)
    end
  end
  
  def sequential_paginator(set)
    html = "<menu>"
    
    unless set.is_first_page?
      html << '<li>' + link_to("&laquo; Previous", params.merge(:after_id => set.first_id)) + '</li>'
    end
    
    unless set.is_last_page?
      html << '<li>' + link_to("Next &raquo;", params.merge(:before_id => set.last_id)) + '</li>'
    end
    
    html << "</menu>"
    html.html_safe
  end
  
  def numbered_paginator(set, &block)
    html = "<menu>"
    window = 3
    if set.total_pages <= (window * 2) + 5
      1.upto(set.total_pages) do |page|
        html << numbered_paginator_item(page, set.current_page, &block)
      end
    elsif set.current_page <= window + 2
      1.upto(set.current_page + window) do |page|
        html << numbered_paginator_item(page, set.current_page, &block)
      end
      html << numbered_paginator_item("...", set.current_page, &block)
      html << numbered_paginator_final_item(set.total_pages, set.current_page, &block)
    
    elsif set.current_page >= set.total_pages - (window + 1)
      html << numbered_paginator_item(1, set.current_page, &block)
      html << numbered_paginator_item("...", set.current_page, &block)
      (set.current_page - window).upto(set.total_pages) do |page|
        html << numbered_paginator_item(page, set.current_page, &block)
      end
    else
      html << numbered_paginator_item(1, set.current_page, &block)
      html << numbered_paginator_item("...", set.current_page, &block)
      (set.current_page - window).upto(set.current_page + window) do |page|
        html << numbered_paginator_item(page, set.current_page, &block)
      end
      html << numbered_paginator_item("...", set.current_page, &block)
      html << numbered_paginator_final_item(set.total_pages, set.current_page, &block)
    end
    html << "</menu>"
    html.html_safe
  end
  
  def numbered_paginator_final_item(total_pages, current_page, &block)
    if total_pages <= 1000
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
