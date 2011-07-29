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
  
  def mod_link_to_user(user, positive_or_negative)
    html = ""
    html << link_to(user.name, user_path(user))
    
    if positive_or_negative == :positive
      html << " [" + link_to("+", new_user_feedback_path(:user_record => {:category => "positive"})) + "]"

      unless user.is_privileged?
        html << " [" + link_to("invite", moderator_invitations_path(:invitation => {:name => user.name, :level => User::Levels::CONTRIBUTOR})) + "]"
      end
    else
      html << " [" + link_to("&ndash;", new_user_feedback_path(:user_record => {:category => "negative", :user_id => user.id})) + "]"
    end
    
    html
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
      
    when "artist_versions"
      /^\/artist/
      
    when "moderator/post/dashboards"
      /^\/post/
      
    when "moderator/dashboards"
      /^\/moderator/
      
    else
      /^\/#{controller}/
    end
  end
end
