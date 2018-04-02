FactoryBot.define do
  factory(:post_disapproval) do
    reason { %w(breaks_rules poor_quality disinterest).sample }
    message { FFaker::Lorem.sentence }
  end
end
