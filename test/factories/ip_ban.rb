FactoryBot.define do
  factory(:ip_ban) do
    creator
    reason { Faker::Lorem.sentence }
    ip_addr { Faker::Internet.public_ip_v4_address }
  end
end
