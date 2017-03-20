module PostAppealsHelper
  def post_appeal_reasons(post)
    html = []
    html << '<ul>'

    post.appeals.each do |appeal|
      reason = DText.parse_inline(appeal.reason).html_safe
      user = link_to_user(appeal.creator)
      ip = link_to_ip(appeal.creator_ip_addr)
      time = time_ago_in_words_tagged(appeal.created_at)

      html << "<li>#{reason} - #{user} (#{ip}) #{time}</li>"
    end

    html << '</ul>'
    html.join("\n").html_safe
  end
end
