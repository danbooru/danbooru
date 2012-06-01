FactoryGirl.define do
  factory(:forum_post) do
    body {Faker::Lorem.sentences.join(" ")}
  end
end