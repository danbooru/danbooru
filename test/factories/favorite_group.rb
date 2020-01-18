FactoryBot.define do
  factory :favorite_group do
    creator
    name { FFaker::Lorem.word }
  end
end
