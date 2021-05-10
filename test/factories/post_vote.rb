FactoryBot.define do
  factory(:post_vote) do
    user factory: :gold_user
    post
    score { [-1, 1].sample }
  end
end
