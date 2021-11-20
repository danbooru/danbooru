FactoryBot.define do
  factory :favorite_group do
    creator
    name { SecureRandom.uuid }

    factory :private_favorite_group do
      creator factory: :gold_user
      is_public { false }
    end
  end
end
