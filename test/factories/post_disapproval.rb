FactoryBot.define do
  factory(:post_disapproval) do
    user
    post
    reason { PostDisapproval::REASONS.sample }
    message { FFaker::Lorem.sentence }
  end
end
