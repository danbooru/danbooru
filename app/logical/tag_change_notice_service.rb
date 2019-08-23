module TagChangeNoticeService
  extend self

  def get_forum_topic_id(tag)
    Cache.get("tcn:#{tag}")
  end

  def update_cache(affected_tags, forum_topic_id)
    affected_tags.each do |tag|
      Cache.put("tcn:#{tag}", forum_topic_id, 1.week)
    end
  end
end
