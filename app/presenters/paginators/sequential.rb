module Paginators
  class Sequential
    attr_reader :template, :source
    delegate :url, :to => :source
    
    def initialize(template, source)
      @template = template
      @source = source
    end
    
    def pagination_html
      html = "<menu>"
      html << '<li>' + template.link_to("&laquo; Previous", prev_url) + '</li>'
      if next_url
        html << '<li>' + template.link_to("Next &raquo;", next_url) + '</li>'
      end
      html << "</menu>"
      html.html_safe
    end
    
    def prev_url
      template.request.env["HTTP_REFERER"] 
    end
    
    def next_url
      @next_url ||= url(template)
    end
  end
end
