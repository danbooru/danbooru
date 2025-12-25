FactoryBot.define do
  factory(:forum_post) do
    creator
    topic factory: :forum_topic
    body { Faker::Lorem.paragraph }
  end
end
