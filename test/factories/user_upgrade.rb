FactoryBot.define do
  factory :user_upgrade do
    recipient factory: :member_user
    purchaser { recipient }
    upgrade_type { "gold" }
    status { "pending" }
    transaction_id { nil }

    factory :self_gold_upgrade do
      upgrade_type { "gold" }
    end

    factory :self_platinum_upgrade do
      upgrade_type { "platinum" }
    end

    factory :self_gold_to_platinum_upgrade do
      recipient factory: :gold_user
      upgrade_type { "gold_to_platinum" }
    end

    factory :gift_gold_upgrade do
      purchaser factory: :user
      upgrade_type { "gold" }
    end

    factory :gift_platinum_upgrade do
      purchaser factory: :user
      upgrade_type { "platinum" }
    end

    factory :gift_gold_to_platinum_upgrade do
      recipient factory: :gold_user
      purchaser factory: :user
      upgrade_type { "gold_to_platinum" }
    end
  end
end
