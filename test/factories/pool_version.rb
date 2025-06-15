FactoryBot.define do
  factory(:pool_version) do
    pool factory: :pool
    updater factory: :user
    name { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    category { "series" }
  end
end
