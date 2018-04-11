FactoryBot.define do
  factory(:ban) do |f|
    banner :factory => :admin_user
    reason {FFaker::Lorem.words.join(" ")}
    duration 60
  end
end
