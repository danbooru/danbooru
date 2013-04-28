FactoryGirl.define do
  factory(:note) do
    creator :factory => :user
    post
    x 0
    y 0
    width 0
    height 0
    is_active true
    body {Faker::Lorem.sentences.join(" ")}
    updater_id :factory => :user
    updater_ip_addr "127.0.0.1"
  end
end
