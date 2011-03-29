module PostFlagsHelper
  def post_flag_reasons(post)
    post.flags.map do |flag|
      content_tag("span") do
        (flag.reason + " (" + link_to(flag.creator.name, user_path(flag.creator_id)) + ")").html_safe
      end
    end.join("; ").html_safe
  end
end
