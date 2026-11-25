FactoryBot.define do
  factory :note do
    post
    x { 1 }
    y { 1 }
    width { 10 }
    height { 10 }
    is_active { true }
    body { Faker::Lorem.paragraph }
  end
end
