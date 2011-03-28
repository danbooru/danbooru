module PostAppealsHelper
  def post_appeal_reason(post)
    post.appeals.map do |appeal|
      content_tag("span", :class => "flag-and-reason-count") do
        appeal.reason + " (" + link_to(appeal.creator.name, :controller => "user", :action => "show", :id => appeal.creator_id) + ")"
      end
    end.join("; ")
  end
end