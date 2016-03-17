module PostFlagsHelper
  def post_flag_reasons(post)
    html = []
    html << '<ul>'

    post.flags.each do |flag|
      html << '<li>'
      html << DTextRagel.parse_inline(flag.reason).html_safe

      if CurrentUser.is_moderator?
        html << ' - ' + link_to_user(flag.creator)
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
