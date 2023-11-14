FactoryBot.define do
  factory(:dmail) do
    owner factory: :user
    from factory: :user
    to factory: :user
    title {FFaker::Lorem.words.join(" ")}
    body {FFaker::Lorem.sentences.join(" ")}
  end
end
