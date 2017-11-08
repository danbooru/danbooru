module PostFlagsHelper
  def post_flag_reasons(post)
    html = []
    html << '<ul>'

    post.flags.each do |flag|
      html << '<li>'
      html << format_text(flag.reason, inline: true)

      if CurrentUser.can_view_flagger_on_post?(flag)
        html << " - #{link_to_user(flag.creator)}"
        if CurrentUser.is_moderator?
           html << " (#{link_to_ip(flag.creator_ip_addr)})"
        end
      end

      html << ' - ' + time_ago_in_words_tagged(flag.created_at)

      if flag.is_resolved?
        html << ' <span class="resolved">RESOLVED</span>'
      end

      html << '</li>'
    end

    html << '</ul>'
    html.join("\n").html_safe
  end
end
