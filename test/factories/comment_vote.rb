FactoryBot.define do
  factory(:comment_vote) do
    user
    score {1}
  end
end
