module PostFlagsHelper
  def post_flag_reasons(post)
    html = []
    html << '<ul>'
    
    post.flags.each do |flag|
      html << '<li>' + flag.reason
      
      if CurrentUser.is_janitor?
        html << ' - ' + link_to(flag.creator.name, user_path(flag.creator))
      end

      html << ' - ' + time_ago_in_words_tagged(flag.created_at) + '</li>'
    end
    
    html << '</ul>'
    html.join("\n").html_safe
  end
end
