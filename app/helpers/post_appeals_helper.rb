module PostAppealsHelper
  def post_appeal_reasons(post)
    html = []
    html << '<ul>'
    
    post.appeals.each do |appeal|
      html << '<li>' + appeal.reason + ' - ' + link_to(appeal.creator.name, user_path(appeal.creator)) + ' ' + time_ago_in_words_tagged(appeal.created_at) + '</li>'
    end
    
    html << '</ul>'
    html.join("\n").html_safe
  end
end