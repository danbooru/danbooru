FactoryBot.define do
  factory(:note) do
    post
    x 1
    y 1
    width 1
    height 1
    is_active true
    body {FFaker::Lorem.sentences.join(" ")}
  end
end
