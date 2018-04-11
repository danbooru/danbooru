FactoryBot.define do
  factory(:wiki_page) do
    creator :factory => :user
    title {FFaker::Lorem.words.join(" ")}
    body {FFaker::Lorem.sentences.join(" ")}
  end
end
