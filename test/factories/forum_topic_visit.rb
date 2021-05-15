FactoryBot.define do
  factory(:forum_topic_visit) do
    user
    forum_topic
    last_read_at { Time.zone.now }
  end
end
