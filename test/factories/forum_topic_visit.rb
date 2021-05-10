FactoryBot.define do
  factory(:forum_topic_visit) do
    user
    forum_topic
  end
end
