FactoryGirl.define do
  factory(:comment) do |f|
    post
    body {Faker::Lorem.sentences.join(" ")}
  end
end
