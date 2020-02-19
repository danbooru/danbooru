FactoryBot.define do
  factory(:post_disapproval) do
    user
    reason { %w(breaks_rules poor_quality disinterest).sample }
    message { FFaker::Lorem.sentence }
  end
end
