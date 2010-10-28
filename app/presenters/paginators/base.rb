module Paginators
  class Base < Presenter
    def sequential_pagination_html(template)
      html = "<menu>"
      prev_url = template.request.env["HTTP_REFERER"]
      next_url = sequential_link(template)
      html << %{<li><a href="#{prev_url}">&laquo; Previous</a></li>}
      if post_set.posts.any?
        html << %{<li><a href="#{next_url}">Next &raquo;</a></li>}
      end
      html << "</menu>"
      html.html_safe
    end
  
    def numbered_pagination_html(template)
      html = "<menu>"
      window = 3
      if total_pages <= (window * 2) + 5
        1.upto(total_pages) do |page|
          html << numbered_pagination_item(template, page, current_page)
        end
      elsif current_page <= window + 2
        1.upto(current_page + window) do |page|
          html << numbered_pagination_item(template, page, current_page)
        end
        html << numbered_pagination_item(template, "...", current_page)
        html << numbered_pagination_item(template, total_pages, current_page)
      
      elsif current_page >= total_pages - (window + 1)
        html << numbered_pagination_item(template, 1, current_page)
        html << numbered_pagination_item(template, "...", current_page)
        (current_page - window).upto(total_pages) do |page|
          html << numbered_pagination_item(template, page, current_page)
        end
      else
        html << numbered_pagination_item(template, 1, current_page)
        html << numbered_pagination_item(template, "...", current_page)
        (current_page - window).upto(current_page + window) do |page|
          html << numbered_pagination_item(template, page, current_page)
        end
        html << numbered_pagination_item(template, "...", current_page)
        html << numbered_pagination_item(template, total_pages, current_page)
      end
      html << "</menu>"
      html.html_safe
    end
  
    protected
      def numbered_pagination_item(template, page, current_page)
        html = "<li>"
        if page == "..."
          html << "..."
        elsif page == current_page
          html << page.to_s
        else
          html << paginated_link(template, page)
        end
        html << "</li>"
        html.html_safe
      end
      
      def total_pages
        raise NotImplementedError
      end
      
      def current_page
        raise NotImplementedError
      end
    
      def sequential_link(template)
        raise NotImplementedError
      end
    
      def paginated_link(template, page)
        raise NotImplementedError
      end
  end
end
