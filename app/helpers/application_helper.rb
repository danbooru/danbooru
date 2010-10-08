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

  def error_messages_for(instance_name)
    instance = instance_variable_get("@#{instance_name}")
    
    if instance.errors.any?
      %{<div class="error-messages"><h1>There were errors</h1><p>#{instance.__send__(:errors).full_messages.join(", ")}</div>}.html_safe
    else
      ""
    end
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
