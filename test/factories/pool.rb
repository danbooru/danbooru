FactoryBot.define do
  factory(:pool) do
    name { "pool_#{rand(100..1_000_099)}" }
    description { Faker::Lorem.paragraph }
  end
end
