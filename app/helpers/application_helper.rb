module ApplicationHelper
  def nav_link_to(text, url, options = nil)
    if nav_link_match(params[:controller], url)
      klass = "current"
    else
      klass = nil
    end

    content_tag("li", link_to(text, url, options), :class => klass)
  end
  
  def format_text(text, options = {})
    DText.parse(text)
  end
  
protected
  def nav_link_match(controller, url)
    url =~ case controller
    when "tag_aliases", "tag_implications"
      /^\/tags/
      
    when "sessions", "user_maintenance"
      /^\/users/
      
    when "forum_posts"
      /^\/forum_topics/
      
    else
      /^\/#{controller}/
    end
  end
end
