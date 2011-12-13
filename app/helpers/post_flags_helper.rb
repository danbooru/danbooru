module PostFlagsHelper
  def post_flag_reasons(post)
    html = []
    html << '<ul>'
    
    post.flags.each do |flag|
      html << '<li>' + flag.reason + ' - ' + link_to(flag.creator.name, user_path(flag.creator)) + ' ' + time_ago_in_words(flag.created_at) + ' ago</li>'
    end
    
    html << '</ul>'
    html.join("\n").html_safe
  end
end
