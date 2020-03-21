FactoryBot.define do
  factory(:comment_vote) do
    comment
    user
    score {1}
  end
end
