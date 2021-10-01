FactoryBot.define do
  factory :favorite_group do
    creator
    name { SecureRandom.uuid }
  end
end
