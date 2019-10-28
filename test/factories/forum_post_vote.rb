FactoryBot.define do
  factory(:forum_post_vote) do
    creator
    forum_post
    score { [-1, 0, 1].sample }
  end
end
