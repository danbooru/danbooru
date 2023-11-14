FactoryBot.define do
  factory(:post_disapproval) do
    user factory: :approver_user
    post factory: :post, is_pending: true
    reason { PostDisapproval::REASONS.sample }
    message { FFaker::Lorem.sentence }
  end
end
