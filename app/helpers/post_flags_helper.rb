module PostFlagsHelper
  def post_flag_reason(post)
    post.flags.map do |flag|
      content_tag("span", :class => "flag-and-reason-count") do
        flag.reason + " (" + link_to(flag.creator.name, :controller => "user", :action => "show", :id => flag.creator_id) + ")"
      end
    end.join("; ")
  end
end
