FactoryBot.define do
  factory(:forum_post) do
    creator
    body {FFaker::Lorem.sentences.join(" ")}
  end
end
