FactoryGirl.define do
  factory(:wiki_page) do
    creator :factory => :user
    title {Faker::Lorem.words.join(" ")}
    body {Faker::Lorem.sentences.join(" ")}
  end
end
