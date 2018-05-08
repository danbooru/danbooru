FactoryBot.define do
  factory(:post_approval) do
    user factory: :moderator_user
    post factory: :post, is_pending: true
  end
end
