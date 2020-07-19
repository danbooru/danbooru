FactoryBot.define do
  factory(:post_flag) do
    creator factory: :user, created_at: 2.weeks.ago
    post
    reason {"xxx"}
    is_resolved {false}
  end
end
