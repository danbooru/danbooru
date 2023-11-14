FactoryBot.define do
  factory(:comment) do |f|
    creator
    post
    body {FFaker::Lorem.sentences.join(" ")}
  end
end
