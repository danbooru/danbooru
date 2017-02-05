FactoryGirl.define do
  factory :favorite_group do
    name { FFaker::Lorem.word }
    creator
  end
end
