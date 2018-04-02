FactoryBot.define do
  factory(:forum_post) do
    body {FFaker::Lorem.sentences.join(" ")}
  end
end
