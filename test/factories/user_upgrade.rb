FactoryBot.define do
  factory(:user_upgrade) do
    recipient { create(:member_user) }
    purchaser { recipient }
    upgrade_type { "gold" }
    status { "pending" }
    stripe_id { nil }

    factory(:self_gold_upgrade) do
      upgrade_type { "gold" }
    end

    factory(:self_platinum_upgrade) do
      upgrade_type { "platinum" }
    end

    factory(:self_gold_to_platinum_upgrade) do
      recipient { create(:gold_user) }
      upgrade_type { "gold_to_platinum" }
    end

    factory(:gift_gold_upgrade) do
      purchaser { create(:user) }
      upgrade_type { "gold" }
    end

    factory(:gift_platinum_upgrade) do
      purchaser { create(:user) }
      upgrade_type { "platinum" }
    end

    factory(:gift_gold_to_platinum_upgrade) do
      recipient { create(:gold_user) }
      purchaser { create(:user) }
      upgrade_type { "gold_to_platinum" }
    end
  end
end
