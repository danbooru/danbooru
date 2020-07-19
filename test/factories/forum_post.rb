FactoryBot.define do
  factory(:forum_post) do
    creator
    topic factory: :forum_topic
    body {FFaker::Lorem.sentences.join(" ")}
  end
end
