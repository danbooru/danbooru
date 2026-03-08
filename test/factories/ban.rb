FactoryBot.define do
  factory(:ban) do
    banner factory: :admin_user
    user
    reason { Faker::Lorem.sentence }
    duration { 1.week }
  end
end
