FactoryBot.define do
  factory(:dmail) do
    to :factory => :user
    title {FFaker::Lorem.words.join(" ")}
    body {FFaker::Lorem.sentences.join(" ")}
  end
end
