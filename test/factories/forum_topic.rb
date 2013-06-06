FactoryGirl.define do
  factory(:forum_topic) do
    title {Faker::Lorem.words.join(" ")}
    is_sticky false
    is_locked false
    category_id 0
  end
end
