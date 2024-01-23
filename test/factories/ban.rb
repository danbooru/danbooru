FactoryBot.define do
  factory(:ban) do |f|
    banner :factory => :admin_user
    user
    reason { Faker::Lorem.sentence }
    duration { 1.week }
  end
end
