module TagsHelper
  def tag_post_count_style(tag)
    @highest_post_count ||= Tag.highest_post_count
    width_percent = Math.log([tag.post_count, 1].max, @highest_post_count) * 100
    "background: linear-gradient(to left, #DDD #{width_percent}%, white #{width_percent}%)"
  end
end
