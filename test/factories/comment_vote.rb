FactoryBot.define do
  factory(:comment_vote) do
    comment
    user
    score {1}
    is_deleted { false }
  end
end
