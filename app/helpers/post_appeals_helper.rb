module PostAppealsHelper
  def post_appeal_reasons(post)
    html = []
    html << '<ul>'

    post.appeals.each do |appeal|
      reason = format_text(appeal.reason, inline: true)
      user = link_to_user(appeal.creator)
      if CurrentUser.is_moderator?
        ip = "(#{link_to_ip(appeal.creator_ip_addr)})"
      else
        ip = ""
      end
      time = time_ago_in_words_tagged(appeal.created_at)
      link = "[#{link_to("Show",post_appeal_path(appeal))}]"

      html << "<li>#{reason} - #{user} #{ip} - #{time} #{link}</li>"
    end

    html << '</ul>'
    html.join("\n").html_safe
  end
end
