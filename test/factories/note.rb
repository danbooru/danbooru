FactoryBot.define do
  factory(:note) do
    post
    x 1
    y 1
    width 1
    height 1
    is_active true
    body {FFaker::Lorem.sentences.join(" ")}
    updater_ip_addr "127.0.0.1"
  end
end
