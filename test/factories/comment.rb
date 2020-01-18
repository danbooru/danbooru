FactoryBot.define do
  factory(:comment) do |f|
    creator
    post
    creator_ip_addr { FFaker::Internet.ip_v4_address }
    body {FFaker::Lorem.sentences.join(" ")}
  end
end
