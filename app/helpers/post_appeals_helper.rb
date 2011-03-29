module PostAppealsHelper
  def post_appeal_reasons(post)
    post.appeals.map do |appeal|
      content_tag("span", :class => "flag-and-reason-count") do
        (appeal.reason + " (" + link_to(appeal.creator.name, user_path(appeal.creator_id)) + ")").html_safe
      end
    end.join("; ").html_safe
  end
end