FactoryBot.define do
  factory :comment do
    creator
    post
    body { Faker::Lorem.paragraph }
  end
end
