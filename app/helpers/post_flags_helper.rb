module PostFlagsHelper
  def post_flag_reasons(post)
    html = []
    html << '<ul>'

    post.flags.each do |flag|
      separator = ""
      reason = format_text(flag.reason, inline: true)
      if CurrentUser.can_view_flagger_on_post?(flag)
        user = link_to_user(flag.creator)
        separator = "-"
      else
        user = ""
      end
      if CurrentUser.is_moderator? && CurrentUser.can_view_flagger_on_post?(flag)
        ip = "(#{link_to_ip(flag.creator_ip_addr)})"
      else
        ip = ""
      end
      time = time_ago_in_words_tagged(flag.created_at)
      link = "[#{link_to("Show",post_flag_path(flag))}]"
      if flag.is_resolved?
        resolved = '<span class="resolved">RESOLVED</span>'
      else
        resolved = ""
      end

      html << "<li>#{reason} - #{user} #{ip} #{separator} #{time} #{link} #{resolved}</li>"
    end

    html << '</ul>'
    html.join("\n").html_safe
  end
end
