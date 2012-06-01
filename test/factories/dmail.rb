FactoryGirl.define do
  factory(:dmail) do
    to :factory => :user
    title {Faker::Lorem.words.join(" ")}
    body {Faker::Lorem.sentences.join(" ")}
  end
end
