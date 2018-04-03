FactoryBot.define do
  factory(:comment) do |f|
    post
    body {FFaker::Lorem.sentences.join(" ")}
  end
end
