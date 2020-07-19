FactoryBot.define do
  factory(:post_disapproval) do
    user factory: :moderator_user
    post factory: :post, is_pending: true
    reason { PostDisapproval::REASONS.sample }
    message { FFaker::Lorem.sentence }
  end
end
