FactoryBot.define do
  factory(:post_disapproval) do
    user
    post
    reason { %w(breaks_rules poor_quality disinterest).sample }
    message { FFaker::Lorem.sentence }
  end
end
