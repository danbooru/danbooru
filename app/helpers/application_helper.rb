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
      %{<div class="error-messages ui-state-error ui-corner-all"><span class="ui-icon ui-icon-alert"></span> <strong>Error</strong>: #{instance.__send__(:errors).full_messages.join(", ")}</div>}.html_safe
    else
      ""
    end
  end
  
  def compact_time(time)
    if time > Time.now.beginning_of_day
      time.strftime("%H:%M")
    elsif time > Time.now.beginning_of_year
      time.strftime("%b %e")
    else
      time.strftime("%b %e, %Y")
    end
  end
  
protected
  def nav_link_match(controller, url)
    url =~ case controller
    when "sessions", "users"
      /^\/(session|users)/
      
    when "forum_posts"
      /^\/forum_topics/
      
    when "uploads"
      /^\/post/
    
    when "post_versions"
      /^\/post/
    
    when "pool_versions"
      /^\/pool/
      
    when "note_versions"
      /^\/note/

    else
      /^\/#{controller}/
    end
  end
end
