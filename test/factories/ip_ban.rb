FactoryBot.define do
  factory(:ip_ban) do
    creator
    reason { FFaker::Lorem.words.join(" ") }
    ip_addr { FFaker::Internet.ip_v4_address }
  end
end
