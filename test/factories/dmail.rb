FactoryBot.define do
  factory(:dmail) do
    owner factory: :user
    from factory: :user
    to factory: :user
    creator_ip_addr { FFaker::Internet.ip_v4_address }
    title {FFaker::Lorem.words.join(" ")}
    body {FFaker::Lorem.sentences.join(" ")}
  end
end
