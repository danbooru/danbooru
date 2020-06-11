FactoryBot.define do
  factory(:post_lock) do
    creator
    post
    reason {FFaker::Lorem.words.join(" ")}
  end
end
