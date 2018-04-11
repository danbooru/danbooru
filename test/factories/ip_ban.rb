FactoryBot.define do
  factory(:ip_ban) do
    creator :factory => :user
    reason {FFaker::Lorem.words.join(" ")}
    ip_addr "127.0.0.2"
  end
end
