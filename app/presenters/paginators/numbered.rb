module Paginators
  class Numbered
    attr_reader :template, :source
    delegate :url, :total_pages, :current_page, :to => :source
    
    def initialize(template, source)
      @template = template
      @source = source
    end
    
    def pagination_html
      html = "<menu>"
      window = 3
      if total_pages <= (window * 2) + 5
        1.upto(total_pages) do |page|
          html << pagination_item(page, current_page)
        end
      elsif current_page <= window + 2
        1.upto(current_page + window) do |page|
          html << pagination_item(page, current_page)
        end
        html << pagination_item("...", current_page)
        html << pagination_item(total_pages, current_page)
      
      elsif current_page >= total_pages - (window + 1)
        html << pagination_item(1, current_page)
        html << pagination_item("...", current_page)
        (current_page - window).upto(total_pages) do |page|
          html << pagination_item(page, current_page)
        end
      else
        html << pagination_item(1, current_page)
        html << pagination_item("...", current_page)
        (current_page - window).upto(current_page + window) do |page|
          html << pagination_item(page, current_page)
        end
        html << pagination_item("...", current_page)
        html << pagination_item(total_pages, current_page)
      end
      html << "</menu>"
      html.html_safe
    end

  protected
    def pagination_item(page, current_page)
      html = "<li>"
      if page == "..."
        html << "..."
      elsif page == current_page
        html << page.to_s
      else
        html << template.link_to(page, url(template, :page => page))
      end
      html << "</li>"
      html.html_safe
    end
  end
end
