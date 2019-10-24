FactoryBot.define do
  factory(:wiki_page) do
    title {FFaker::Lorem.words.join(" ")}
    body {FFaker::Lorem.sentences.join(" ")}
  end
end
